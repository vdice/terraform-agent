# tfc-agent Helm Chart

A Helm chart for running the [Terraform Cloud Agent](https://developer.hashicorp.com/terraform/cloud-docs/agents) on Kubernetes.  
Optionally supports sidecar injection, eg a [Tailscale](https://tailscale.com) sidecar container.

## Features

- Deploys the official [`hashicorp/tfc-agent`](https://hub.docker.com/r/hashicorp/tfc-agent) container
- Expects the Terraform Cloud Agent token to be stored in a Kubernetes `Secret`

---

## Prerequisites

- Kubernetes cluster
- Helm 3.2+
- A valid [Terraform Cloud Agent token](https://developer.hashicorp.com/terraform/cloud-docs/agents#generating-agent-tokens)

---

## Installing the Chart

Clone or download this chart, then install it with:

```bash
# Create the Kubernetes Secret containing the agent token
kubectl create secret generic tfc-agent-token \
  --from-literal=TFC_AGENT_TOKEN="${TFC_AGENT_TOKEN}"

# Install the chart
helm install tfc-agent . \
  --set tokenSecretKeyRef.name="tfc-agent-token" \
  --set tokenSecretKeyRef.key="TFC_AGENT_TOKEN"
```

---

## All values

| Key                         | Type   | Default               | Description                                                                        |
| --------------------------- | ------ | --------------------- | ---------------------------------------------------------------------------------- |
| `image.repository`          | string | `hashicorp/tfc-agent` | TFC Agent image repository.                                                        |
| `image.tag`                  | string | `1.23`                | TFC Agent image tag.                                                               |
| `image.pullPolicy`           | string | `IfNotPresent`        | TFC Agent image pull policy.                                                       |
| `replicaCount`               | int    | `1`                   | Number of agent replicas to run.                                                   |
| `tokenSecretKeyRef.name`     | string | `"tfc-agent-token"`   | **Required**. Name of the Kubernetes Secret storing the agent token.               |
| `tokenSecretKeyRef.key`      | string | `"TFC_AGENT_TOKEN"`   | **Required**. The key for the agent token stored in the Kubernetes Secret.         |
