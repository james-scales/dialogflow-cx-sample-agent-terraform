# Dependency chain:
#   bucket → security_settings → agent → intents + pages → playbook → flows
#   tool → tool_version
#   flows + pages + intents + playbook + generator + webhook → version → environment

# variable "gen_app_builder_engine" {
#   description = "Gen App Builder engine resource name — sourced from tfvars until gen_app_builder is migrated to modules"
#   type        = string
#   default = null
# }

#---------- Storage ----------#
module "bucket" {
  source = "./modules/bucket"

  bucket_name     = var.bucket_name
  bucket_location = var.bucket_location
}

#---------- Security Settings ----------#
# Security Settings for the Dialogflow CX agent. Location-level resource.
module "security_settings" {
  source = "./modules/security_settings"

  project_id = var.project_id
  location   = var.dialogflow_cx_location
}

#---------- Agent ----------#
module "agent" {
  source = "./modules/agent"

  location               = var.dialogflow_cx_location
  audio_export_gcs_uri   = "${module.bucket.bucket_url}/prefix-"
  security_settings_id   = module.security_settings.security_settings_id
  gen_app_builder_engine = module.gen_app_builder.engine_name
}

#---------- Entity Types ----------#
# Entity types for policy types (auto, home, etc.) and incident types (theft, vandalism, etc.) referenced in pages and intents.
module "entity_types" {
  source = "./modules/entity_types"

  agent_id = module.agent.agent_id
}

#---------- Intents ----------#
# Training phases for payment, claim, and policy inquiry intents that trigger the main conversation paths. 
# Intent parameters reference the entity types defined above.
module "intents" {
  source = "./modules/intents"

  agent_id                     = module.agent.agent_id
  policy_type_entity_type_id   = module.entity_types.policy_type_entity_type_id
  incident_type_entity_type_id = module.entity_types.incident_type_entity_type_id
}

#---------- Pages ----------#
# Pages define the flow of conversation based on user intent and collected information.
module "pages" {
  source = "./modules/pages"

  agent_start_flow             = module.agent.agent_start_flow
  policy_type_entity_type_id   = module.entity_types.policy_type_entity_type_id
  incident_type_entity_type_id = module.entity_types.incident_type_entity_type_id
  policy_lookup_webhook_id     = module.webhook.policy_lookup_webhook_id
}

#---------- Playbook ----------#
# Playbook contains conditional instructions that the agent can execute at runtime to enrich responses with dynamic data. 
# It references the tool defined below to fetch real-time policy information.
module "playbook" {
  source = "./modules/playbook"

  agent_id = module.agent.agent_id
}

#---------- Flows ----------#
# Every agent has a Default Start Flow that defines the initial conversation path. This module manages the Default Start Flow's transition routes, 
# which direct the conversation based on user intent and page parameters.
module "flows" {
  source = "./modules/flows"

  agent_id = module.agent.agent_id

  make_payment_intent    = module.intents.make_payment_intent_id
  file_claim_intent      = module.intents.file_claim_intent_id
  policy_inquiry_intent  = module.intents.policy_inquiry_intent_id
  accident_report_intent = module.intents.accident_report_intent_id

  collect_policy_number_page = module.pages.collect_policy_number_page_id
  collect_claim_details_page = module.pages.collect_claim_details_page_id
  policy_inquiry_page        = module.pages.policy_inquiry_page_id
  accident_assistance_page   = module.pages.accident_assistance_page_id
}

#---------- Generative Settings ----------#
# Generative Settings configure the agent's generative features, including LLM behavior, safety filters, and knowledge connectors.
module "generative_settings" {
  source = "./modules/generative_settings"

  agent_id = module.agent.agent_id
}

#---------- Generator ----------#
# This Generator produces dynamic, contextually aware responses for the agent to use in the accident assistance conversation path.
module "generator" {
  source = "./modules/generator"

  agent_id = module.agent.agent_id
}

#---------- Tool ----------#
# The Tool module defines a function spec for the Policy Lookup Tool, which the Playbook can call at runtime to fetch real-time policy information and populate agent responses.
module "tool" {
  source = "./modules/tool"

  agent_id = module.agent.agent_id
}

#---------- Tool Version ----------#
# Tool Version snapshots the Policy Lookup Tool at v1.0.0 so that the Playbook can reference a specific, immutable version of the tool when calling it at runtime.
module "tool_version" {
  source = "./modules/tool_version"

  tool_id = module.tool.policy_lookup_tool_id
}

#---------- Flow Version ----------#
# The Flow Version module Snapshots the Default Start Flow at v1.0.0 and triggers agent training.
module "version" {
  source = "./modules/version"

  agent_start_flow = module.agent.agent_start_flow

  depends_on = [
    module.flows,
    module.pages,
    module.intents,
    module.playbook,
    module.generator,
  ]
}

#---------- Environment ----------#
# Environment module allows for testing against a stable version of the agent while keeping the draft flow editable.
# Development environment pinned to v1.0.0 of the Default Start Flow.
module "environment" {
  source = "./modules/environment"

  agent_id              = module.agent.agent_id
  start_flow_version_id = module.version.start_flow_version_id
}

#---------- Test Cases ----------#
# Test cases for regression testing of the main conversation paths. 
# Run via the Dialogflow CX console or: gcloud dialogflow cx test-cases run
module "test_case" {
  source = "./modules/test_case"

  agent_id                      = module.agent.agent_id
  file_claim_intent_id          = module.intents.file_claim_intent_id
  make_payment_intent_id        = module.intents.make_payment_intent_id
  collect_claim_details_page_id = module.pages.collect_claim_details_page_id
  collect_policy_number_page_id = module.pages.collect_policy_number_page_id
  policy_inquiry_intent_id      = module.intents.policy_inquiry_intent_id
  policy_inquiry_page_id        = module.pages.policy_inquiry_page_id
}

#---------- Webhook ----------#
# Policy Lookup Webhook — replace webhook_uri in tfvars with your real
# Webhook defines Cloud Run or Cloud Function endpoint.
module "webhook" {
  source      = "./modules/webhook"
  agent_id    = module.agent.agent_id
  webhook_uri = var.webhook_uri
}

#---------- Gen App Builder Engine ----------#
# Creates the Discovery Engine that backs the Dialogflow CX agent's generative features.
# Must exist before the agent is created so the reference is valid.
module "gen_app_builder" {
  source   = "./modules/gen_app_builder"
  location = var.project_region
}