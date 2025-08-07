variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}

variable "tfc_agent_token" {
  type      = string
  sensitive = true
}

variable "ssh_public_key_filepath" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "aws_region" {
  type = string
}