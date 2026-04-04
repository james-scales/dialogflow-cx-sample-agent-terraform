#---------- Core agent identity ----------#
variable "display_name" {
  description = "Display name of the Dialogflow CX agent"
  type        = string
  default     = "store-order-agent"
}

variable "description" {
  description = "Description of the Dialogflow CX agent"
  type        = string
  default     = "Example description."
}

variable "location" {
  description = "GCP region where the agent is deployed (passed from root var.project_region)"
  type        = string
}

variable "time_zone" {
  description = "Agent time zone (IANA format)"
  type        = string
  default     = "America/Chicago"
}

variable "avatar_uri" {
  description = "URI for the agent's avatar image"
  type        = string
  default     = "https://cloud.google.com/_static/images/cloud/icons/favicons/onecloud/super_cloud.png"
}

#---------- Language settings ----------#
variable "default_language_code" {
  description = "Default language code for the agent (BCP-47 format)"
  type        = string
  default     = "en"
}

variable "supported_language_codes" {
  description = "Additional supported language codes for the agent"
  type        = list(string)
  default     = ["fr", "de", "es"]
}

#---------- Speech-to-text ----------#
variable "enable_spell_correction" {
  description = "Enable automatic spell correction in detect intent requests"
  type        = bool
  default     = true
}

variable "enable_speech_adaptation" {
  description = "Enable speech adaptation for improved recognition accuracy"
  type        = bool
  default     = true
}

variable "audio_export_gcs_uri" {
  description = "GCS URI for audio export destination (injected from bucket module output)"
  type        = string
}

variable "endpointer_sensitivity" {
  description = "Speech endpointer sensitivity (0-100). Higher = more sensitive to end of speech."
  type        = number
  default     = 30
}

variable "no_speech_timeout" {
  description = "Timeout duration when no speech is detected (e.g. '3.500s')"
  type        = string
  default     = "3.500s"
}

variable "use_timeout_based_endpointing" {
  description = "Use timeout-based endpointing instead of model-based"
  type        = bool
  default     = true
}

#---------- DTMF - Telephony integration ----------#
variable "dtmf_enabled" {
  description = "Enable DTMF input (telephony integration)"
  type        = bool
  default     = true
}

variable "dtmf_max_digits" {
  description = "Maximum number of DTMF digits to collect"
  type        = number
  default     = 1
}

variable "dtmf_finish_digit" {
  description = "DTMF digit that signals end of input"
  type        = string
  default     = "#"
}

#---------- Logging ----------#
variable "enable_stackdriver_logging" {
  description = "Enable Stackdriver (Cloud Logging) for the agent"
  type        = bool
  default     = true
}

variable "enable_interaction_logging" {
  description = "Enable interaction logging in the Dialogflow CX console"
  type        = bool
  default     = true
}

variable "enable_consent_based_redaction" {
  description = "Redact PII from logs based on user consent"
  type        = bool
  default     = true
}

#---------- Text-to-Speech ----------#
# Map of language codes to voice synthesis config objects.
# Add or remove languages here; each entry is passed through jsonencode().
# Example: { en = { voice = { name = "en-US-Neural2-A" } } }
variable "tts_voices" {
  description = "Map of language codes to TTS voice synthesis configs"
  type        = any
  default = {
    en = {
      voice = {
        name = "en-US-Neural2-A"
      }
    }
    fr = {
      voice = {
        name = "fr-CA-Neural2-A"
      }
    }
  }
}

#---------- Gen App Builder (optional) ----------#
# Uncomment gen_app_builder_settings in main.tf and set this variable when ready.
# variable "gen_app_builder_engine" {
#   description = "Vertex AI Search / Gen App Builder engine resource name"
#   type        = string
# }

#---------- Playbooks (optional) ----------#
# Uncomment start_playbook in main.tf and set this variable when ready.
# variable "start_playbook" {
#   description = "Dialogflow CX Playbook resource name (Vertex AI Agent Builder)"
#   type        = string
# }

#---------- Agent feature flags ----------#
variable "enable_multi_language_training" {
  description = "Enable multi-language training for the agent"
  type        = bool
  default     = false
}

variable "locked" {
  description = "Lock the agent to prevent edits in the Dialogflow CX console"
  type        = bool
  default     = false
}

variable "enable_answer_feedback" {
  description = "Enable answer feedback collection"
  type        = bool
  default     = false
}

#---------- Personalization ----------#
variable "default_end_user_metadata" {
  description = "Default end-user metadata JSON string passed to the agent for personalization"
  type        = string
  default     = "{\"example-key\": \"example-value\"}"
}
