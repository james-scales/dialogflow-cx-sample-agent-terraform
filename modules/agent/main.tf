resource "google_dialogflow_cx_agent" "agent" {
  display_name             = var.display_name
  description              = var.description
  location                 = var.location
  time_zone                = var.time_zone
  default_language_code    = var.default_language_code
  supported_language_codes = var.supported_language_codes
  avatar_uri               = var.avatar_uri
  enable_spell_correction  = var.enable_spell_correction

  speech_to_text_settings {
    # Extracted to var.enable_speech_adaptation (default: true)
    enable_speech_adaptation = var.enable_speech_adaptation
  }

  advanced_settings {
    audio_export_gcs_destination {
      uri = var.audio_export_gcs_uri
    }

    speech_settings {
      # Extracted to individual vars — tune per environment in tfvars
      endpointer_sensitivity        = var.endpointer_sensitivity
      no_speech_timeout             = var.no_speech_timeout
      use_timeout_based_endpointing = var.use_timeout_based_endpointing

      # NOTE: models block removed — contained example/placeholder data
      # ("wrench", "1.3kg", "3") copied from Google API docs.
      # Add back with real custom model names if needed.
    }

    #---------- DTMF - Telephony integration ----------#
    # controls how your agent listens for DTMF inputs when connected to a phone line.
    # i.e. you can configure your agent to listen for a specific digit (e.g., "#") to signify the end of user input.
    dtmf_settings {
      # Extracted to vars — override in tfvars for non-telephony deployments
      enabled      = var.dtmf_enabled
      max_digits   = var.dtmf_max_digits
      finish_digit = var.dtmf_finish_digit
    }

    #---------- Logging settings ----------#
    # Includes Stackdriver logging, interaction logging, and consent-based redaction.
    logging_settings {
      # All flags extracted to vars — disable individually per environment as needed
      enable_stackdriver_logging     = var.enable_stackdriver_logging
      enable_interaction_logging     = var.enable_interaction_logging
      enable_consent_based_redaction = var.enable_consent_based_redaction
    }
  }

  #---------- SENSITIVE INFORMATION ----------#
  # git_integration_settings removed — contains hardcoded access_token.
  # Use Secrets Manager data sources to inject the token securely if re-enabling.

  #---------- Text to Speech ----------#
  # Controls how speech is synthesized and how to customize it.
  text_to_speech_settings {
    # Voice config extracted to var.tts_voices — add/remove languages in tfvars
    synthesize_speech_configs = jsonencode(var.tts_voices)
  }

  #---------- Gen App Builder ----------#
  # NOTE: Commented out — requires a real Vertex AI Search / Gen App Builder engine ID.
  # FORMAT: projects/{Project ID}/locations/{Location ID}/collections/{Collection ID}/engines/{Engine ID}
  # Uncomment and set var.gen_app_builder_engine in tfvars when ready.
  # gen_app_builder_settings {
  #   engine = var.gen_app_builder_engine
  # }

  # NOTE: Commented out — requires a real Dialogflow CX Playbook ID.
  # Only needed if using Vertex AI Agent Builder Playbooks.
  # Uncomment and set var.start_playbook in tfvars when ready.
  # start_playbook = var.start_playbook

  enable_multi_language_training = var.enable_multi_language_training
  locked                         = var.locked

  answer_feedback_settings {
    enable_answer_feedback = var.enable_answer_feedback
  }

  #---------- SENSITIVE INFORMATION ----------#
  # client_certificate_settings removed — contains hardcoded certificate/key paths.
  # Reference Secrets Manager versions via data sources before re-enabling.

  #---------- Personalization settings ----------#
  # Allows providing additional context about the user to generate personalized responses.
  personalization_settings {
    # Extracted to var.default_end_user_metadata — update JSON in tfvars per environment
    # Suggested format: { "age": "$session.params.age" }
    default_end_user_metadata = var.default_end_user_metadata
  }
}
