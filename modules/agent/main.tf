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

      # NOTE: Example model, can be removed if not needed
      models = {
        "AUDIO_ENCODING_MULAW"     = "telephony"
        "AUDIO_ENCODING_LINEAR_16" = "latest_short"
        "AUDIO_ENCODING_OGG_OPUS"  = "latest_short"
      }
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

  #---------- Git Integration ----------#
  # access_token accepts a Secret Manager secret version path directly —
  # no data source needed. Enable by passing github_token_secret_id from
  # the secrets module and setting github_repo_uri in tfvars.
  # dynamic "git_integration_settings" {
  #   for_each = var.github_token_secret_id != null && var.github_repo_uri != null ? [1] : []
  #   content {
  #     github_settings {
  #       display_name    = var.github_display_name
  #       repository_uri  = var.github_repo_uri
  #       tracking_branch = var.github_tracking_branch
  #       access_token    = "${var.github_token_secret_id}/versions/latest"
  #       branches        = var.github_branches
  #     }
  #   }
  # }

  #---------- Text to Speech ----------#
  # Controls how speech is synthesized and how to customize it.
  text_to_speech_settings {
    # Voice config extracted to var.tts_voices — add/remove languages in tfvars
    synthesize_speech_configs = jsonencode(var.tts_voices)
  }

  #---------- Gen App Builder ----------#
  # FORMAT: projects/{Project ID}/locations/{Location ID}/collections/{Collection ID}/engines/{Engine ID}
  # Set in tfvars to enable Gen App Builder integration; leave null to disable and avoid errors.
  gen_app_builder_settings {
    engine = var.gen_app_builder_engine
  }

  security_settings              = var.security_settings_id
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
