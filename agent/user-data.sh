#!/bin/bash
set -euo pipefail

# Update and install dependencies
apt-get update -y
apt-get install -y curl gnupg unzip

%{~ if tailscale_exit_node ~}
apt-get install -y iptables

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf

# Set up NAT (masquerade outgoing traffic)
IFACE=$(ip route show default | awk '/default/ {print $5}')
iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE

# Persist iptables rules
if command -v netfilter-persistent >/dev/null 2>&1; then
    netfilter-persistent save
elif command -v iptables-save >/dev/null 2>&1; then
    iptables-save > /etc/iptables.rules
    cat <<EOF >/etc/network/if-pre-up.d/iptables
#!/bin/sh
iptables-restore < /etc/iptables.rules
EOF
    chmod +x /etc/network/if-pre-up.d/iptables
fi
%{~ endif ~}

# Install Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
apt-get update -y
apt-get install -y tailscale

# Start Tailscale with auth key
tailscale up \
    --authkey=${tailscale_auth_key} \
    --hostname=terraform-agent \
    %{~ if tailscale_exit_node ~} --advertise-exit-node %{~ endif ~}

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
ExecStart=/usr/local/bin/tfc-agent -token=${tfc_agent_token} -name=agent1
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
