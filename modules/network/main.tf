#---------- Required APIs ----------#
resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "certificatemanager" {
  project            = var.project_id
  service            = "certificatemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "networksecurity" {
  project            = var.project_id
  service            = "networksecurity.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns" {
  project            = var.project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

#---------- Private Service Connect: Dialogflow API endpoint ----------#
# Reserves a private IP in the VPC that routes traffic to Google APIs (dialogflow.googleapis.com)
# without traversing the public internet. Satisfies the "public endpoints are prohibited" standard.
resource "google_compute_global_address" "psc_endpoint" {
  project      = var.project_id
  name         = var.psc_endpoint_name
  address_type = "INTERNAL"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = var.vpc_network_id

  depends_on = [google_project_service.compute]
}

# Forwarding rule binds the reserved IP to the "all-apis" bundle, which includes
# dialogflow.googleapis.com, secretmanager.googleapis.com, cloudkms.googleapis.com, etc.
# no_automate_dns_zone = false: Terraform auto-creates a private DNS zone routing
# *.googleapis.com to this endpoint within the VPC.
resource "google_compute_global_forwarding_rule" "psc_dialogflow" {
  project               = var.project_id
  name                  = "${var.psc_endpoint_name}-fwd"
  target                = "all-apis"
  network               = var.vpc_network_id
  ip_address            = google_compute_global_address.psc_endpoint.self_link
  load_balancing_scheme = ""
  no_automate_dns_zone  = false

  depends_on = [google_project_service.compute]
}

#---------- Cloud Armor: Webhook WAF policy ----------#
# Protects external-facing webhook endpoints. Applied to the backend service fronting
# the webhook Cloud Run / GKE workload. Attach this policy to your backend service
# via the backend_service.security_policy attribute (not managed here — backend service
# is owned by the webhook workload's deployment).
resource "google_compute_security_policy" "webhook_armor" {
  project = var.project_id
  name    = "dialogflow-webhook-armor"

  #---------- Rate limiting ----------#
  # Throttles requests exceeding var.rate_limit_rpm per IP per minute to prevent abuse.
  rule {
    action   = "throttle"
    priority = "100"
    description = "Rate-limit requests per source IP"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }

    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = var.rate_limit_rpm
        interval_sec = 60
      }
    }
  }

  #---------- OWASP: SQL injection ----------#
  rule {
    action   = "deny(403)"
    priority = "500"
    description = "Block SQL injection attempts (OWASP sqli-stable)"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
  }

  #---------- OWASP: Cross-site scripting ----------#
  rule {
    action   = "deny(403)"
    priority = "600"
    description = "Block XSS attempts (OWASP xss-stable)"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
  }

  #---------- OWASP: Remote code execution ----------#
  rule {
    action   = "deny(403)"
    priority = "700"
    description = "Block remote code execution attempts (OWASP rce-stable)"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('rce-stable')"
      }
    }
  }

  #---------- Default: allow ----------#
  # mTLS (below) is the primary authentication mechanism for webhook callers.
  # Cloud Armor handles protocol-level and injection attack blocking.
  rule {
    action   = "allow"
    priority = "2147483647"
    description = "Default allow — mTLS enforces caller authentication"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  depends_on = [google_project_service.compute]
}

#---------- Certificate Manager: mTLS Trust Config ----------#
# Defines which client Certificate Authorities are trusted for mTLS handshakes.
# The Dialogflow service will present a client certificate signed by one of these CAs.
# var.client_ca_cert_pem: PEM-encoded public CA cert — safe to store in tfvars (not a private key).
resource "google_certificate_manager_trust_config" "webhook_mtls" {
  project  = var.project_id
  name     = "dialogflow-webhook-mtls-trust"
  location = var.location

  trust_stores {
    trust_anchors {
      pem_certificate = var.client_ca_cert_pem
    }
  }

  depends_on = [google_project_service.certificatemanager]
}

#---------- Network Security: Server TLS Policy (enforce mTLS) ----------#
# Attaches to a regional Application Load Balancer HTTPS target proxy to enforce mutual TLS.
# REJECT_INVALID: rejects any client that cannot present a valid certificate signed by the trust config CA.
# To attach: set the target proxy's server_tls_policy attribute to this resource's id.
resource "google_network_security_server_tls_policy" "webhook_mtls" {
  project    = var.project_id
  name       = "dialogflow-webhook-mtls-policy"
  location   = var.location
  allow_open = false

  mtls_policy {
    client_validation_mode         = "REJECT_INVALID"
    client_validation_trust_config = "projects/${var.project_id}/locations/${var.location}/trustConfigs/${google_certificate_manager_trust_config.webhook_mtls.name}"
  }

  depends_on = [google_project_service.networksecurity]
}
