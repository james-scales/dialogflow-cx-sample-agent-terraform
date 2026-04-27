resource "google_dialogflow_cx_entity_type" "policy_type" {
  parent       = var.agent_id
  display_name = "policy_type"
  kind         = "KIND_MAP"

  dynamic "entities" {
    for_each = var.policy_type_entities
    content {
      value    = entities.value.value
      synonyms = entities.value.synonyms
    }
  }
}

# Classifies the nature of a claim event — used to annotate claim.file intent
# training phrases (theft, vandalism, hit-and-run) and passively captured on
# the Collect Claim Details page so adjusters receive incident context upfront.
resource "google_dialogflow_cx_entity_type" "incident_type" {
  parent       = var.agent_id
  display_name = "incident_type"
  kind         = "KIND_MAP"

  dynamic "entities" {
    for_each = var.incident_type_entities
    content {
      value    = entities.value.value
      synonyms = entities.value.synonyms
    }
  }
}

# Mirrors the PolicyLookupTool query_type enum so NLU can extract the specific
# type of policy question from a user utterance and pass it directly to the tool.
resource "google_dialogflow_cx_entity_type" "query_type" {
  parent       = var.agent_id
  display_name = "query_type"
  kind         = "KIND_MAP"

  dynamic "entities" {
    for_each = var.query_type_entities
    content {
      value    = entities.value.value
      synonyms = entities.value.synonyms
    }
  }
}