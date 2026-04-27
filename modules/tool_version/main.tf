# google_dialogflow_cx_tool_version
# Snapshots the Policy Lookup Tool at a specific point in time.
# Environments reference specific versions, which allows you to promote
# a tested tool configuration from development to production safely.

resource "google_dialogflow_cx_tool_version" "policy_lookup_v1" {
  parent       = var.tool_id
  display_name = "1.0.0"

  # Snapshot of the tool at version time — must mirror the tool's current spec
  tool {
    display_name = "PolicyLookupTool"
    description  = "Look up insurance policy details for a given policy number. Returns coverage type, deductible amount, and active add-ons such as roadside assistance or rental car coverage."

    function_spec {
      input_schema = jsonencode({
        type = "object"
        properties = {
          policy_number = {
            type        = "string"
            description = "The customer's insurance policy number"
          }
          query_type = {
            type        = "string"
            description = "The type of information requested"
            enum        = ["coverage", "deductible", "roadside_assistance", "rental_car"]
          }
        }
        required = ["policy_number", "query_type"]
      })

      output_schema = jsonencode({
        type = "object"
        properties = {
          policy_number = {
            type = "string"
          }
          query_type = {
            type = "string"
          }
          result = {
            type        = "string"
            description = "Human-readable answer to the query"
          }
          covered = {
            type        = "boolean"
            description = "Whether the queried item is covered under the policy"
          }
        }
      })
    }
  }
}