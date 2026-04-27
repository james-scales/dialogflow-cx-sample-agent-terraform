resource "google_discovery_engine_data_store" "agentspace_basic" {
  data_store_id               = var.data_store_id
  location                    = "global"
  display_name                = "${var.display_name} Data Store"
  industry_vertical           = "GENERIC"
  content_config              = "NO_CONTENT"
  solution_types              = ["SOLUTION_TYPE_CHAT"]
  create_advanced_site_search = false

  lifecycle {
    ignore_changes = [solution_types]
  }
}

resource "google_discovery_engine_search_engine" "agent_engine" {
  engine_id     = var.engine_id
  collection_id = "default_collection"
  location      = "global"
  display_name  = var.display_name

  data_store_ids = [google_discovery_engine_data_store.agentspace_basic.data_store_id]

  search_engine_config {
  }
}
