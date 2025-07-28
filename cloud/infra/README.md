# Overview

This is the IaC for deploying a development server in the cloud

# Usage

## Requirements
- `pulumi`
- `aws-creds`
- A `Pulumi.<namespace>.yaml` file with the following fields filled out:
```yaml
config:
  aws:region: <REGION>
  networkConfig:
    sshIngressPort: <PORT>
    sshIngressCidrs:
    - <CIDR>
    httpIngressCidrs:
    - <CIDR>
  sshPublicKey: <PUBLIC_KEY>
```

## Deploying
```sh
(export $(aws-creds show); pulumi up)
```

## Destroying
```sh
(export $(aws-creds show); pulumi down)
```