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
  }

}

# Configure the GitHub Provider
provider "github" {
  token = var.GITHUB_TOKEN
}

provider "vultr" {

  api_key = var.VULTR_API_KEY

}

variable "VULTR_API_KEY" {}
variable "GITHUB_TOKEN" {}
variable "GITHUB_REPO" {}
variable "GITHUB_USERNAME" {}