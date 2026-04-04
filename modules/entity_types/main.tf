resource "google_dialogflow_cx_entity_type" "size" {
  parent       = var.agent_id
  display_name = "size"
  kind         = "KIND_MAP"

  # Uses dynamic block so size_entities list can be managed entirely from variables
  dynamic "entities" {
    for_each = var.size_entities
    content {
      value    = entities.value.value
      synonyms = entities.value.synonyms
    }
  }
}
