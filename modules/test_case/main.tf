# google_dialogflow_cx_test_case
# Automated regression tests that verify the agent responds correctly to
# specific inputs. Run via: gcloud dialogflow cx test-cases run ...
# or through the Dialogflow CX console Test Cases tab.
#
# This test verifies the core claim filing path:
#   User: "I need to file a claim"
#   Expected: claim.file intent fires → Collect Claim Details page becomes active

resource "google_dialogflow_cx_test_case" "file_claim_happy_path" {
  parent       = var.agent_id
  display_name = "File a Claim — Happy Path"
  tags         = ["#claim", "#regression"]
  notes        = "Verifies that 'I need to file a claim' matches the claim.file intent and routes to the Collect Claim Details page."

  test_config {
    # Track the policy_number parameter to confirm form collection starts
    tracking_parameters = ["policy_number", "incident_date"]
  }

  test_case_conversation_turns {
    user_input {
      input {
        language_code = "en"
        text {
          text = "I need to file a claim"
        }
      }
      is_webhook_enabled = false
    }

    virtual_agent_output {
      triggered_intent {
        name = var.file_claim_intent_id
      }
      current_page {
        name = var.collect_claim_details_page_id
      }
      text_responses {
        text = ["I'm sorry to hear that. I can help you file a claim. Can you please provide your policy number?"]
      }
    }
  }
}

# Policy Inquiry — verifies the policy.inquiry intent routes to the Policy Inquiry page
resource "google_dialogflow_cx_test_case" "policy_inquiry_happy_path" {
  parent       = var.agent_id
  display_name = "Policy Inquiry — Happy Path"
  tags         = ["#policy", "#regression"]
  notes        = "Verifies that 'What does my policy cover?' matches the policy.inquiry intent and routes to the Policy Inquiry page."

  test_case_conversation_turns {
    user_input {
      input {
        language_code = "en"
        text {
          text = "What does my policy cover?"
        }
      }
      is_webhook_enabled = false
    }

    virtual_agent_output {
      triggered_intent {
        name = var.policy_inquiry_intent_id
      }
      current_page {
        name = var.policy_inquiry_page_id
      }
      text_responses {
        text = ["I can help you with questions about your policy. Could you tell me more about what you would like to know — for example, your coverage details, deductible, or roadside assistance?"]
      }
    }
  }
}

# No-Match Fallback — verifies that an unrecognized utterance on the start flow returns the reprompt message
resource "google_dialogflow_cx_test_case" "no_match_fallback" {
  parent       = var.agent_id
  display_name = "No-Match Fallback — Reprompt"
  tags         = ["#fallback", "#regression"]
  notes        = "Verifies that an utterance that does not match any intent triggers the sys.no-match-default handler and returns an options reprompt."

  test_case_conversation_turns {
    user_input {
      input {
        language_code = "en"
        text {
          text = "xyzzy frobozz nothing here"
        }
      }
      is_webhook_enabled = false
    }

    virtual_agent_output {
      text_responses {
        text = ["I didn't quite catch that. I can help you make a payment, file a claim, or answer questions about your policy. Which would you like?"]
      }
    }
  }
}

# Multi-Turn Claim Filing — verifies the claim form collects policy_number then incident_date
resource "google_dialogflow_cx_test_case" "file_claim_multi_turn" {
  parent       = var.agent_id
  display_name = "File a Claim — Multi-Turn Form Fill"
  tags         = ["#claim", "#multi-turn", "#regression"]
  notes        = "Verifies the claim form fills in sequence: intent fires, agent requests policy number, then requests incident date."

  test_config {
    tracking_parameters = ["policy_number", "incident_date"]
  }

  test_case_conversation_turns {
    user_input {
      input {
        language_code = "en"
        text {
          text = "I was in an accident"
        }
      }
      is_webhook_enabled = false
    }

    virtual_agent_output {
      triggered_intent {
        name = var.file_claim_intent_id
      }
      current_page {
        name = var.collect_claim_details_page_id
      }
      text_responses {
        text = ["I'm sorry to hear that. I can help you file a claim. Can you please provide your policy number?"]
      }
    }
  }

  test_case_conversation_turns {
    user_input {
      input {
        language_code = "en"
        text {
          text = "AUTO-123456"
        }
      }
      is_webhook_enabled = false
    }

    virtual_agent_output {
      current_page {
        name = var.collect_claim_details_page_id
      }
      text_responses {
        text = ["What date did the incident occur?"]
      }
    }
  }
}

resource "google_dialogflow_cx_test_case" "make_payment_happy_path" {
  parent       = var.agent_id
  display_name = "Make a Payment — Happy Path"
  tags         = ["#payment", "#regression"]
  notes        = "Verifies that 'I want to pay my bill' matches the payment.make intent and routes to the Collect Policy Number page."

  test_config {
    tracking_parameters = ["policy_number", "policy_type"]
  }

  test_case_conversation_turns {
    user_input {
      input {
        language_code = "en"
        text {
          text = "I want to pay my bill"
        }
      }
      is_webhook_enabled = false
    }

    virtual_agent_output {
      triggered_intent {
        name = var.make_payment_intent_id
      }
      current_page {
        name = var.collect_policy_number_page_id
      }
      text_responses {
        text = ["Please provide your policy number so I can look up your account."]
      }
    }
  }
}