# google_dialogflow_cx_tool
# Tools are used by Playbooks to perform actions or retrieve information.
# This function tool defines the contract (input/output JSON schema) for a
# client-side policy lookup. The Playbook calls this when the customer asks
# about their specific coverage, deductible, or roadside assistance.

resource "google_dialogflow_cx_tool" "policy_lookup" {
  parent       = var.agent_id
  display_name = "PolicyLookupTool"
  description  = "Look up insurance policy details for a given policy number. Supports coverage, deductible, add-ons (roadside assistance, rental car), payment due dates, active claim status, and agent contact information."

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
          description = "The category of information being requested"
          enum = [
            "coverage",
            "deductible",
            "roadside_assistance",
            "rental_car",
            "payment_due",
            "claim_status",
            "contact_info"
          ]
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
        amount = {
          type        = "number"
          description = "Applicable dollar amount — deductible owed, payment balance, or coverage limit"
        }
        due_date = {
          type        = "string"
          description = "ISO-8601 date of the next payment due or policy expiration"
        }
        status = {
          type        = "string"
          description = "Current status of a claim (e.g. OPEN, IN_REVIEW, APPROVED, CLOSED) or policy"
        }
        next_steps = {
          type        = "array"
          description = "Ordered list of recommended actions for the customer to take"
          items = {
            type = "string"
          }
        }
      }
    })
  }
}