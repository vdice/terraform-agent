Example terraform and Helm chart for a Terraform Cloud agent

- [agent](/agent): terraform for a custom Terraform Cloud agent
    - provisioned via AWS EC2
    - with Tailscale auth
- [charts](/charts): Helm charts for a custom Terraform Cloud agent
    - [tfc-agent](/charts/tfc-agent/) runs a Terraform Cloud agent with generic sidecar support
    - [tfc-agent-tailscale](/charts/tfc-agent-tailscale/) runs a Terraform Cloud gant with specific Tailscale sidecar support
- [demo](/demo): to run in Terraform Cloud using the agent to verify Tailscale access, etc
