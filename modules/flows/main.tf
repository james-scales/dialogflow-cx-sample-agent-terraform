resource "google_dialogflow_cx_flow" "default_start_flow" {
  parent                = var.agent_id
  display_name          = "Default Start Flow"
  description           = "Routes users to the correct flow based on their stated intent."
  is_default_start_flow = true

  # Default Welcome Intent (built-in nil UUID, same across all agents).
  # Responds with a greeting and lists available options.
  transition_routes {
    intent = "${var.agent_id}/intents/00000000-0000-0000-0000-000000000000"
    trigger_fulfillment {
      messages {
        text {
          text = ["Hello, welcome to your insurance virtual assistant. I can help you make a payment, file a claim, or answer questions about your policy. How can I help you today?"]
        }
      }
    }
  }

  transition_routes {
    intent      = var.make_payment_intent
    target_page = var.collect_policy_number_page
  }

  transition_routes {
    intent      = var.file_claim_intent
    target_page = var.collect_claim_details_page
  }

  transition_routes {
    intent      = var.policy_inquiry_intent
    target_page = var.policy_inquiry_page
  }

  transition_routes {
    intent      = var.accident_report_intent
    target_page = var.accident_assistance_page
  }

  # Reprompt when the user's utterance doesn't match any intent.
  # Restates available options so the conversation can recover gracefully.
  event_handlers {
    event = "sys.no-match-default"
    trigger_fulfillment {
      messages {
        text {
          text = ["I didn't quite catch that. I can help you make a payment, file a claim, or answer questions about your policy. Which would you like?"]
        }
      }
    }
  }

  # Check-in message when the channel receives no audio or text input.
  event_handlers {
    event = "sys.no-input-default"
    trigger_fulfillment {
      messages {
        text {
          text = ["Are you still there? Take your time — I can help with payments, claims, or policy questions whenever you're ready."]
        }
      }
    }
  }
}
