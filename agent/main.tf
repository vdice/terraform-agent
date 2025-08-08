provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-agent-key"
  public_key = file(var.ssh_public_key_filepath)
}

resource "aws_security_group" "agent_sg" {
  name = "terraform-agent-sg"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidr_blocks
  }

  dynamic "ingress" {
    for_each = var.tailscale_exit_node ? [1] : []
    content {
      description = "Allow Tailscale UDP"
      from_port   = 41641
      to_port     = 41641
      protocol    = "udp"
      cidr_blocks = var.allowed_ingress_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "terraform_agent" {
  ami             = "ami-0becc523130ac9d5d" # Ubuntu 22.04 LTS
  instance_type   = "t3.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.agent_sg.name]

  tags = {
    Name = "terraform-agent"
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    tailscale_auth_key  = var.tailscale_auth_key
    tfc_agent_token     = var.tfc_agent_token
    tailscale_exit_node = var.tailscale_exit_node
  })
}
