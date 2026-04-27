variable "agent_id" {
  description = "Dialogflow CX agent ID (passed from agent module output)"
  type        = string
}

variable "policy_type_entities" {
  description = "List of insurance policy type entity values and their synonyms"
  type = list(object({
    value    = string
    synonyms = list(string)
  }))
  default = [
    { value = "auto", synonyms = ["auto", "automobile", "car", "vehicle", "car insurance"] },
    { value = "home", synonyms = ["home", "homeowners", "house", "property", "renters"] },
    { value = "life", synonyms = ["life", "life insurance", "term life", "whole life"] },
    { value = "motorcycle", synonyms = ["motorcycle", "bike", "motorbike"] },
    { value = "commercial", synonyms = ["commercial", "business", "fleet", "company vehicle"] },
  ]
}

variable "incident_type_entities" {
  description = "Claim incident types — annotates claim.file training phrases and is passively captured on the Collect Claim Details page"
  type = list(object({
    value    = string
    synonyms = list(string)
  }))
  default = [
    { value = "accident", synonyms = ["accident", "collision", "crash", "fender bender"] },
    { value = "theft", synonyms = ["theft", "stolen", "car theft", "vehicle theft"] },
    { value = "vandalism", synonyms = ["vandalism", "vandalized", "keyed", "graffiti", "property damage"] },
    { value = "weather_damage", synonyms = ["weather damage", "hail", "flood", "storm", "tornado", "hurricane", "fallen tree"] },
    { value = "hit_and_run", synonyms = ["hit and run", "hit-and-run", "left the scene", "no other driver"] },
  ]
}

variable "query_type_entities" {
  description = "Policy query types — mirrors the PolicyLookupTool query_type enum so NLU can extract the query type from user utterances"
  type = list(object({
    value    = string
    synonyms = list(string)
  }))
  default = [
    { value = "coverage", synonyms = ["coverage", "covered", "what's covered", "protection"] },
    { value = "deductible", synonyms = ["deductible", "out of pocket", "my deductible"] },
    { value = "roadside_assistance", synonyms = ["roadside assistance", "roadside", "towing", "tow truck", "jump start", "flat tire"] },
    { value = "rental_car", synonyms = ["rental car", "rental", "loaner car", "car rental"] },
    { value = "payment_due", synonyms = ["payment due", "bill", "balance", "amount owed", "premium due"] },
    { value = "claim_status", synonyms = ["claim status", "status of my claim", "claim update", "claim approved", "claim progress"] },
    { value = "contact_info", synonyms = ["contact", "agent contact", "phone number", "reach my agent", "talk to someone"] },
  ]
}