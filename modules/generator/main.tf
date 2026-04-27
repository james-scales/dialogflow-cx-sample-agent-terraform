# google_dialogflow_cx_generator
# A Generator lets the LLM produce dynamic text at runtime based on a prompt
# and optional session context. This generator is used to produce empathetic,
# context-aware responses for post-accident conversations.
# Reference this generator ID in Playbook instructions or fulfillment messages.

resource "google_dialogflow_cx_generator" "claims_empathy" {
  parent        = var.agent_id
  display_name  = "Claims-Empathy-Generator"
  language_code = "en"

  prompt_text {
    text = "You are an empathetic insurance agent helping a customer who has just been in a vehicle accident. The customer's current situation: $situation. Generate a calm, reassuring response that: 1) acknowledges their stress, 2) confirms the next step they should take, 3) uses plain language with no jargon. Keep the response under 3 sentences."
  }

  llm_model_settings {
    model       = "gemini-2.5-flash"
    prompt_text = "Respond with empathy, clarity, and brevity. Avoid legalese."
  }

  model_parameter {
    temperature = 0.4
  }
}