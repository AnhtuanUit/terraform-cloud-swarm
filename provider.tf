terraform {

  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = ">= 2.10.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    slack = {
      source  = "pablovarela/slack"
      version = "~> 1.0"
    }
  }

}

# Configure the GitHub Provider
provider "github" {
  token = var.GITHUB_TOKEN
}

provider "vultr" {
  api_key = var.VULTR_API_KEY
}

# Configure Slack Provider
provider "slack" {
  token = var.SLACK_TOKEN
}

variable "VULTR_API_KEY" {}
variable "GITHUB_TOKEN" {}
variable "GITHUB_REPO" {}
variable "GITHUB_USERNAME" {}
variable "SLACK_TOKEN" {}