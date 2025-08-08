variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}

variable "tailscale_exit_node" {
  description = "Run as a tailscale exit node"
  type        = bool
  default     = false
}

variable "tfc_agent_token" {
  type      = string
  sensitive = true
}

variable "ssh_public_key_filepath" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "aws_region" {
  type = string
}

variable "allowed_ingress_cidr_blocks" {
  type = list(string)
}