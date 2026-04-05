# Dependency chain: bucket → agent → entity_types → intents + pages → flows
# Security modules: iam, kms, secrets, network, vpc_sc, dlp, monitoring
# dlp depends on bucket (needs bucket name); all others are independent
#
# To configure environment-specific values, update terraform.tfvars.
# Module defaults are defined in each module's variables.tf.

#---------- IAM ----------#
# module "iam" {
#   source = "./modules/iam"

#   project_id                 = var.project_id
#   agent_builder_group        = var.agent_builder_group
#   webhook_developer_group    = var.webhook_developer_group
#   cicd_service_account_email = var.cicd_service_account_email
# }

#---------- KMS / CMEK ----------#
# module "kms" {
#   source = "./modules/kms"

#   project_id     = var.project_id
#   project_number = var.project_number
#   location       = var.project_region

#   # Override key_ring_name, crypto_key_name, rotation_period, or protection_level in tfvars if needed
# }

#---------- Secret Manager ----------#
# module "secrets" {
#   source = "./modules/secrets"

#   project_id         = var.project_id
#   location           = var.project_region
#   next_rotation_time = var.secret_next_rotation_time

#   # Override secrets map in tfvars to set accessor service accounts or add additional secrets
# }

#---------- Network / mTLS ----------#
# module "network" {
#   source = "./modules/network"

#   project_id         = var.project_id
#   location           = var.project_region
#   vpc_network_id     = var.vpc_network_id
#   client_ca_cert_pem = var.client_ca_cert_pem

#   # Override psc_endpoint_name or rate_limit_rpm in tfvars if needed
# }

#---------- VPC Service Controls ----------#
# WARNING: Applying this module in enforced mode will immediately restrict API access.
# Set existing_access_policy_name if your org already has an Access Policy.
# Populate ingress_identities with the groups/service accounts that need Dialogflow access.
# module "vpc_sc" {
#   source = "./modules/vpc_sc"

#   project_id     = var.project_id
#   project_number = var.project_number
#   org_id         = var.org_id

#   existing_access_policy_name = var.existing_access_policy_name
#   ingress_identities          = var.vpc_sc_ingress_identities
#   ingress_access_level        = var.vpc_sc_ingress_access_level
#   egress_identities           = var.vpc_sc_egress_identities
# }

#---------- DLP ----------#
# Depends on bucket module — passes the Dialogflow export bucket name as the scan target.
# module "dlp" {
#   source = "./modules/dlp"

#   project_id      = var.project_id
#   location        = var.project_region
#   gcs_bucket_name = module.bucket.bucket_name

#   # Override findings_dataset_id, scan_recurrence_period, or findings_pubsub_topic in tfvars if needed
# }

#---------- Monitoring & Alerting ----------#
# module "monitoring" {
#   source = "./modules/monitoring"

#   project_id          = var.project_id
#   location            = var.project_region
#   alert_email_address = var.alert_email_address

#   # Override audit_log_bucket_name, audit_log_retention_days, or alert thresholds in tfvars if needed
# }

#---------- Storage ----------#
module "bucket" {
  source = "./modules/bucket"

  # Override defaults in terraform.tfvars if bucket name/location varies by environment
  bucket_name     = var.bucket_name
  bucket_location = var.bucket_location
}

#---------- Agent ----------#
module "agent" {
  source = "./modules/agent"
  location = var.project_region
  audio_export_gcs_uri = "${module.bucket.bucket_url}/prefix-"

  # Override any agent defaults here or in terraform.tfvars as needed:
  # display_name                   = var.agent_display_name
  # time_zone                      = var.agent_time_zone
  # enable_multi_language_training = true
  # locked                         = true
}

#---------- Entity Types ----------#
module "entity_types" {
  source = "./modules/entity_types"
  agent_id = module.agent.agent_id

  # size_entities uses module default — override in tfvars to add/remove sizes
}

# #---------- Intents ----------#
module "intents" {
  source = "./modules/intents"
  agent_id            = module.agent.agent_id
  size_entity_type_id = module.entity_types.size_entity_type_id
}

# #---------- Pages ----------#
module "pages" {
  source = "./modules/pages"
  agent_start_flow    = module.agent.agent_start_flow
  size_entity_type_id = module.entity_types.size_entity_type_id

  # Override response messages in terraform.tfvars if copy varies by environment:
  # store_location_message = "Our store is at 123 Main St."
  # store_hours_message    = "We are open 9am-6pm Mon-Fri."
}

# #---------- Flows ----------#
module "flows" {
  source = "./modules/flows"

  project_id     = var.project_id
  project_region = var.project_region
  agent_name     = module.agent.agent_name

  store_location_intent = module.intents.store_location_intent_id
  store_hours_intent    = module.intents.store_hours_intent_id
  new_order_intent      = module.intents.new_order_intent_id

  store_location_page = module.pages.store_location_page_id
  store_hours_page    = module.pages.store_hours_page_id
  new_order_page      = module.pages.new_order_page_id
}
