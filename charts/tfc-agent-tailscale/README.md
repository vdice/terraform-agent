# tfc-agent Helm Chart

A Helm chart for running the [Terraform Cloud Agent](https://developer.hashicorp.com/terraform/cloud-docs/agents) on Kubernetes.  
Optionally supports connecting the agent to a [Tailscale](https://tailscale.com) tailnet via a sidecar container.

## Features

- Deploys the official [`hashicorp/tfc-agent`](https://hub.docker.com/r/hashicorp/tfc-agent) container
- Stores the Terraform Cloud Agent token securely in a Kubernetes `Secret`
- Optionally runs a Tailscale sidecar to route agent traffic through a tailnet
- Configurable via `values.yaml` or `--set` flags

---

## Prerequisites

- Kubernetes cluster
- Helm 3.2+
- A valid [Terraform Cloud Agent token](https://developer.hashicorp.com/terraform/cloud-docs/agents#generating-agent-tokens)
- (Optional) A [Tailscale auth key](https://tailscale.com/kb/1085/auth-keys) if you want the agent to connect to a tailnet

---

## Installing the Chart

Clone or download this chart, then install it with:

```bash
helm install tfc-agent-tailscale . \
  --set agentToken="<tfc-agent-token>"
```

Optionally supplying a tailscale auth key to connect to a tailnet:

```bash
helm install tfc-agent-tailscale . \
  --set agentToken="<tfc-agent-token>" \
  --set tailscale.authKey="<tailscale-auth-key>"
```

---

## All values

| Key                    | Type   | Default               | Description                                                                        |
| ---------------------- | ------ | --------------------- | ---------------------------------------------------------------------------------- |
| `agentToken`           | string | `""`                  | **Required**. Terraform Cloud Agent token. Stored in a Kubernetes Secret.          |
| `image.repository`     | string | `hashicorp/tfc-agent` | TFC Agent image repository.                                                        |
| `image.tag`            | string | `1.23`              | TFC Agent image tag.                                                               |
| `image.pullPolicy`     | string | `IfNotPresent`        | TFC Agent image pull policy.                                                       |
| `tailscale.authKey`     | string | `""`                  | Optional. Tailscale auth key. If provided, a Tailscale sidecar container will run. |
| `tailscale.image`      | string | `tailscale/tailscale` | Tailscale image repository.                                                        |
| `tailscale.tag`        | string | `stable`              | Tailscale image tag.                                                               |
| `tailscale.pullPolicy` | string | `IfNotPresent`        | Tailscale image pull policy.                                                       |
| `replicaCount`         | int    | `1`                   | Number of agent replicas to run.                                                   |
