terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.70.0"
    }
  }
}

variable "project_id" {}

variable "region" {}

variable "zone" {}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
