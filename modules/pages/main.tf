# Page response messages are kept as module-internal content (business copy,
# not infrastructure config). Override by passing vars if messages need to vary
# by environment.

# ── Payment Flow pages ────────────────────────────────────────────────────────

resource "google_dialogflow_cx_page" "collect_policy_number" {
  parent       = var.agent_start_flow
  display_name = "Collect Policy Number"

  form {
    parameters {
      display_name = "policy_number"
      entity_type  = "projects/-/locations/-/agents/-/entityTypes/sys.any"
      is_list      = false
      redact       = false
      required     = true

      fill_behavior {
        initial_prompt_fulfillment {
          return_partial_responses = false
          messages {
            text {
              text = ["Please provide your policy number so I can look up your account."]
            }
          }
        }
      }
    }

    parameters {
      display_name = "policy_type"
      entity_type  = var.policy_type_entity_type_id
      is_list      = false
      redact       = false
      required     = true

      fill_behavior {
        initial_prompt_fulfillment {
          return_partial_responses = false
          messages {
            text {
              text = ["What type of policy is this for — auto, home, or life?"]
            }
          }
        }
      }
    }
  }

  transition_routes {
    condition   = "$page.params.status = \"FINAL\""
    target_page = google_dialogflow_cx_page.confirm_payment.id

    trigger_fulfillment {
      return_partial_responses = false
      webhook                  = var.policy_lookup_webhook_id
      tag                      = "lookup_balance"
      messages {
        text {
          text = ["Thank you. I've located your $session.params.policy_type policy. Let me pull up your payment details."]
        }
      }
    }
  }
}

resource "google_dialogflow_cx_page" "confirm_payment" {
  parent       = var.agent_start_flow
  display_name = "Confirm Payment"

  entry_fulfillment {
    return_partial_responses = false
    messages {
      text {
        text = [var.confirm_payment_message]
      }
    }
  }

  transition_routes {
    condition   = "true"
    target_page = google_dialogflow_cx_page.payment_complete.id
  }
}

resource "google_dialogflow_cx_page" "payment_complete" {
  parent       = var.agent_start_flow
  display_name = "Payment Complete"

  entry_fulfillment {
    return_partial_responses = false
    messages {
      text {
        text = ["Your payment has been processed successfully. A confirmation will be sent to your email on file. Is there anything else I can help you with?"]
      }
    }
  }

  transition_routes {
    condition   = "true"
    target_page = "${var.agent_start_flow}/pages/END_SESSION"
  }
}

# ── Claim Flow pages ──────────────────────────────────────────────────────────

resource "google_dialogflow_cx_page" "collect_claim_details" {
  parent       = var.agent_start_flow
  display_name = "Collect Claim Details"

  form {
    parameters {
      display_name = "policy_number"
      entity_type  = "projects/-/locations/-/agents/-/entityTypes/sys.any"
      is_list      = false
      redact       = false
      required     = true

      fill_behavior {
        initial_prompt_fulfillment {
          return_partial_responses = false
          messages {
            text {
              text = ["I'm sorry to hear that. I can help you file a claim. Can you please provide your policy number?"]
            }
          }
        }
      }
    }

    # Passively captures the incident type from the opening utterance
    # (e.g. "stolen" → theft, "vandalized" → vandalism) without prompting.
    # The claim.file intent annotates these terms so the parameter is often
    # pre-filled by the time the form runs.
    parameters {
      display_name = "incident_type"
      entity_type  = var.incident_type_entity_type_id
      is_list      = false
      redact       = false
      required     = false
    }

    parameters {
      display_name = "incident_date"
      entity_type  = "projects/-/locations/-/agents/-/entityTypes/sys.date"
      is_list      = false
      redact       = false
      required     = true

      fill_behavior {
        initial_prompt_fulfillment {
          return_partial_responses = false
          messages {
            text {
              text = ["What date did the incident occur?"]
            }
          }
        }
      }
    }
  }

  transition_routes {
    condition   = "$page.params.status = \"FINAL\""
    target_page = google_dialogflow_cx_page.claim_confirmation.id

    trigger_fulfillment {
      return_partial_responses = false
      messages {
        text {
          text = ["Thank you. I have your policy number and incident date of $session.params.incident_date."]
        }
      }
    }
  }
}

resource "google_dialogflow_cx_page" "claim_confirmation" {
  parent       = var.agent_start_flow
  display_name = "Claim Confirmation"

  entry_fulfillment {
    return_partial_responses = false
    messages {
      text {
        text = [var.claim_confirmation_message]
      }
    }
  }

  transition_routes {
    condition   = "true"
    target_page = "${var.agent_start_flow}/pages/END_SESSION"
  }
}

# ── Accident Assistance page ─────────────────────────────────────────────────
# Intermediate hop: accident.report intent → this page → Accident-Assistant Playbook.
# Needed because google_dialogflow_cx_flow transition routes do not support
# target_playbook — only page-level transition routes do.

resource "google_dialogflow_cx_page" "accident_assistance" {
  parent       = var.agent_start_flow
  display_name = "Accident Assistance"

  # target_playbook is not supported by the Terraform Google provider.
  # After apply: open this page in the Dialogflow CX console, edit the
  # transition route, and set the target to the Accident-Assistant Playbook.
  transition_routes {
    condition   = "true"
    target_page = "${var.agent_start_flow}/pages/END_SESSION"
  }
}

# ── Policy Inquiry page ───────────────────────────────────────────────────────
# Entry point for open-ended policy questions. In the console you can attach
# a Playbook handoff to this page. Via REST API it returns a holding response
# and ends the session — extend as needed.

resource "google_dialogflow_cx_page" "policy_inquiry" {
  parent       = var.agent_start_flow
  display_name = "Policy Inquiry"

  entry_fulfillment {
    return_partial_responses = false
    messages {
      text {
        text = ["I can help you with questions about your policy. Could you tell me more about what you would like to know — for example, your coverage details, deductible, or roadside assistance?"]
      }
    }
  }

  transition_routes {
    condition   = "true"
    target_page = "${var.agent_start_flow}/pages/END_SESSION"
  }
}