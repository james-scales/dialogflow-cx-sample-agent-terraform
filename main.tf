# Dependency chain: bucket → agent → entity_types → intents + pages → flows
#
# To configure environment-specific values, update terraform.tfvars.
# Module defaults are defined in each module's variables.tf.

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
