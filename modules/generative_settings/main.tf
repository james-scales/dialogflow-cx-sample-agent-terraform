# google_dialogflow_cx_generative_settings
# Singleton per agent per language — configures the LLM behaviour for generative
# features across the agent: fallback responses, safety filters, and knowledge
# connector business context.

resource "google_dialogflow_cx_generative_settings" "insurance_gen_settings" {
  parent        = var.agent_id
  language_code = var.language_code

  # Give the LLM context about who the agent is and what it does
  knowledge_connector_settings {
    business                    = "Demo Insurance Agency"
    agent                       = "Virtual Insurance Assistant"
    agent_identity              = "a helpful and empathetic insurance virtual agent"
    business_description        = "VA agent that helps customers with policies, payments, & claims"
    agent_scope                 = "insurance policy questions, payment processing, and claims filing"
    disable_data_store_fallback = false
  }

  # Safety: block phrases associated with insurance fraud or abuse
  generative_safety_settings {
    default_banned_phrase_match_strategy = "PARTIAL_MATCH"
    banned_phrases {
      text          = "fake claim"
      language_code = "en"
    }
    banned_phrases {
      text          = "insurance fraud"
      language_code = "en"
    }
  }

  # Fallback template used when the LLM cannot generate a confident response
  fallback_settings {
    selected_prompt = "insurance-fallback"
    prompt_templates {
      display_name = "insurance-fallback"
      prompt_text  = "You are a helpful insurance assistant. If you cannot answer the customer's question with confidence, apologize and offer to connect them to a live agent."
      frozen       = false
    }
  }

  llm_model_settings {
    model       = "gemini-2.5-flash"
    prompt_text = "You are an empathetic insurance virtual assistant. Always prioritize customer safety and well-being before discussing policy or financial details."
  }
}