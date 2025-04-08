variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Google provider region (e.g. for functions)"
  default     = "us-central1"
}

variable "app_engine_region" {
  type        = string
  description = "App Engine region (used to lock Firestore)"
  default     = "us-central"
}

variable "secret_region" {
  type        = string
  description = "Region to store secrets in Secret Manager"
  default     = "us-central1"
}

variable "prompt_names" {
  type        = list(string)
  description = "Prompt secret keys to provision"
  default     = [
    "oss_purist_prompt",
    "vc_strategist_prompt",
    "tech_architect_prompt",
    "trend_watcher_prompt",
    "aggregator_prompt"
  ]
}
