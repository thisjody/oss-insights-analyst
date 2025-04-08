############################################
# terraform/main.tf
############################################

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.5"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Firestore requires App Engine region lock
resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.app_engine_region
}

# Gemini API key
resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id = "gemini_api_key"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.secret_region
      }
    }
  }
}

# Agent prompt secrets
resource "google_secret_manager_secret" "agent_prompts" {
  for_each  = toset(var.prompt_names)
  secret_id = each.key
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.secret_region
      }
    }
  }
}

# Output all secret names
output "secret_names" {
  value = concat(
    [google_secret_manager_secret.gemini_api_key.name],
    [for prompt in google_secret_manager_secret.agent_prompts : prompt.name]
  )
}
