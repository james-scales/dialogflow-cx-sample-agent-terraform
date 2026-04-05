variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "GCP region for Certificate Manager and Server TLS Policy resources (must match the load balancer region)"
  type        = string
}

#---------- Private Service Connect ----------#
variable "vpc_network_id" {
  description = "Self-link or ID of the VPC network used for the PSC endpoint (e.g. projects/my-project/global/networks/default)"
  type        = string
}

variable "psc_endpoint_name" {
  description = "Name of the PSC global address and forwarding rule"
  type        = string
  default     = "psc-dialogflow-endpoint"
}

#---------- Cloud Armor ----------#
variable "rate_limit_rpm" {
  description = "Maximum requests per minute per source IP before Cloud Armor throttles to deny(429)"
  type        = number
  default     = 100
}

#---------- mTLS ----------#
# The client CA certificate (PEM) used to validate webhook client certificates.
# This is the public CA cert — safe to store in tfvars. Do NOT store private keys here.
# To get this value: export the CA cert from your certificate authority in PEM format.
variable "client_ca_cert_pem" {
  description = "PEM-encoded public CA certificate used to validate mTLS client certificates on webhook calls"
  type        = string
  sensitive   = false
}
