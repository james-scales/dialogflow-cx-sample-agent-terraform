# Page response messages are kept as module-internal content (business copy,
# not infrastructure config). Override by passing vars if messages need to vary
# by environment.

resource "google_dialogflow_cx_page" "store_location" {
  parent       = var.agent_start_flow
  display_name = "Store Location"

  entry_fulfillment {
    return_partial_responses = false
    messages {
      text {
        text = [var.store_location_message]
      }
    }
  }
}

resource "google_dialogflow_cx_page" "store_hours" {
  parent       = var.agent_start_flow
  display_name = "Store Hours"

  entry_fulfillment {
    return_partial_responses = false
    messages {
      text {
        text = [var.store_hours_message]
      }
    }
  }
}

resource "google_dialogflow_cx_page" "new_order" {
  parent       = var.agent_start_flow
  display_name = "New Order"

  form {
    parameters {
      display_name = "color"
      # sys.color is a built-in Dialogflow system entity — no module output needed
      entity_type = "projects/-/locations/-/agents/-/entityTypes/sys.color"
      is_list     = false
      redact      = false
      required    = true

      fill_behavior {
        initial_prompt_fulfillment {
          return_partial_responses = false
          messages {
            text {
              text = ["What color would you like?"]
            }
          }
        }
      }
    }

    parameters {
      display_name = "size"
      entity_type = var.size_entity_type_id
      is_list     = false
      redact      = false
      required    = true

      fill_behavior {
        initial_prompt_fulfillment {
          return_partial_responses = false
          messages {
            text {
              text = ["What size do you want?"]
            }
          }
        }
      }
    }
  }

  transition_routes {
    condition = "$page.params.status = \"FINAL\""
    target_page = google_dialogflow_cx_page.order_confirmation.id

    trigger_fulfillment {
      return_partial_responses = false
      messages {
        text {
          text = ["You have selected a $session.params.size, $session.params.color shirt."]
        }
      }
    }
  }

  transition_routes {
    condition = "true"
    trigger_fulfillment {
      return_partial_responses = false
      messages {
        text {
          text = ["I'd like to collect a bit more information from you."]
        }
      }
    }
  }
}

resource "google_dialogflow_cx_page" "order_confirmation" {
  parent       = var.agent_start_flow
  display_name = "Order Confirmation"

  entry_fulfillment {
    return_partial_responses = false
    messages {
      text {
        text = ["You can pick up your order for a $session.params.size $session.params.color shirt in 7 to 10 business days. Goodbye."]
      }
    }
  }

  transition_routes {
    condition = "true"
    target_page = "${var.agent_start_flow}/pages/END_SESSION"
  }
}
