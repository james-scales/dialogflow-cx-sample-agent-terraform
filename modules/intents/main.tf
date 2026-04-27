# Training phrases are kept as module-internal content — they are business logic,
# not infrastructure config, so they don't need to be variables.

# Intent: customer wants to pay their bill / deductible
resource "google_dialogflow_cx_intent" "make_payment" {
  parent       = var.agent_id
  display_name = "payment.make"
  priority     = 500000

  parameters {
    entity_type = var.policy_type_entity_type_id
    id          = "policy_type"
    is_list     = false
    redact      = false
  }

  training_phrases {
    repeat_count = 1
    parts { text = "I want to pay my bill" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Pay my premium" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I need to pay my deductible" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Make a payment" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Pay my " }
    parts {
      parameter_id = "policy_type"
      text         = "auto"
    }
    parts { text = " insurance bill" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "How do I pay my invoice?" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I owe a payment" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Process my payment" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Pay my balance" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "My bill is due" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Settle my account" }
  }
}

# Intent: customer wants to file a claim
resource "google_dialogflow_cx_intent" "file_claim" {
  parent       = var.agent_id
  display_name = "claim.file"
  priority     = 500000

  parameters {
    entity_type = var.policy_type_entity_type_id
    id          = "policy_type"
    is_list     = false
    redact      = false
  }

  parameters {
    entity_type = var.incident_type_entity_type_id
    id          = "incident_type"
    is_list     = false
    redact      = false
  }

  training_phrases {
    repeat_count = 1
    parts { text = "I need to file a claim" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I was in an accident" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "My car was damaged" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "File a " }
    parts {
      parameter_id = "policy_type"
      text         = "auto"
    }
    parts { text = " claim" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Submit a claim" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Start a claim" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Report an accident" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "My car was " }
    parts {
      parameter_id = "incident_type"
      text         = "stolen"
    }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "My property was " }
    parts {
      parameter_id = "incident_type"
      text         = "vandalized"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      parameter_id = "incident_type"
      text         = "hit and run"
    }
    parts { text = " — someone hit my car and left" }
  }
}

# Intent: customer is dealing with an accident — routes directly to the Accident-Assistant Playbook.
# Kept separate from policy.inquiry so structured policy questions (deductible, coverage)
# are handled by the Policy Inquiry page, not the generative Playbook.
resource "google_dialogflow_cx_intent" "accident_report" {
  parent       = var.agent_id
  display_name = "accident.report"
  priority     = 500000

  training_phrases {
    repeat_count = 1
    parts { text = "I just had a car accident" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I was in an accident and need help" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I just got into a crash" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "My car was hit" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I was involved in a collision" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Someone rear-ended me" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I had a fender bender" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I need accident help" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "There was an incident on the road" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "I was just in a crash and I don't know what to do" }
  }
}

# Intent: customer has a policy question (routes to Policy Inquiry page, NOT the Playbook)
resource "google_dialogflow_cx_intent" "policy_inquiry" {
  parent       = var.agent_id
  display_name = "policy.inquiry"
  priority     = 500000

  training_phrases {
    repeat_count = 1
    parts { text = "I have a question about my policy" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "What does my policy cover?" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Do I have roadside assistance?" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Am I covered for a rental car?" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Policy question" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "What is my deductible?" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Tell me about my coverage" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Coverage question" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "What's the status of my claim?" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "Is my claim approved?" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "When is my payment due?" }
  }
  training_phrases {
    repeat_count = 1
    parts { text = "How do I contact my agent?" }
  }
}