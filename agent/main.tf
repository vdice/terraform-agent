provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform-agent-key"
  public_key = file(var.ssh_public_key_filepath)
}

resource "aws_security_group" "agent_sg" {
  name        = "terraform-agent-sg"
  description = "Allow SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For SSH access – restrict in production
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

  user_data = <<-EOF
    #!/bin/bash
    # Update and install dependencies
    apt-get update -y
    apt-get install -y curl gnupg unzip

    # Install Tailscale
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    apt-get update -y
    apt-get install -y tailscale

    # Start Tailscale with auth key
    tailscale up --authkey=${var.tailscale_auth_key} --hostname=terraform-agent

    # Install Terraform Cloud Agent
    curl -L -o tfc-agent.zip https://releases.hashicorp.com/tfc-agent/1.23.1/tfc-agent_1.23.1_linux_amd64.zip
    unzip tfc-agent.zip && rm tfc-agent.zip
    mv tfc-agent* /usr/local/bin/

    # Create systemd service
    cat <<EOT > /etc/systemd/system/tfc-agent.service
    [Unit]
    Description=Terraform Cloud Agent
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/tfc-agent -token=${var.tfc_agent_token} -name=agent1
    Restart=always
    RestartSec=5
    Environment=PATH=/usr/local/bin:/usr/bin:/bin

    [Install]
    WantedBy=multi-user.target
    EOT

    # Start and enable the service
    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable tfc-agent
    systemctl start tfc-agent
  EOF
}
