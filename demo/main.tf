terraform {
  required_version = ">= 1.4"

  cloud {
    organization = "vdice"

    workspaces {
      name = "terraform-agent-demo"
    }
  }

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}

provider "http" {}

# Make a call to an internal service over Tailscale
data "http" "internal_status" {
  url = "http://${var.internal_service_address}/health"

  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

output "internal_service_health" {
  value = data.http.internal_status.response_body
}
