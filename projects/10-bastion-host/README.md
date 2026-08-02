# Bastion Host

This project covers configuring a bastion host architecture between two existing AWS EC2 instances.

## Overview

I created two EC2 instances: **Instance A**, configured for deployment and server configuration tasks, and **Instance B**, which acts as the application server. The task was to set up the full connection between them so that Instance A works as a bastion host — configuring SSH access from Instance A to Instance B, and restricting Instance B's security group so it only accepts SSH connections from Instance A, rather than being open to direct SSH access from any source.

## Key steps

- Generated an SSH key pair on Instance A and added the public key to Instance B for authentication.
- Configured SSH access from Instance A to Instance B.
- Reviewed and updated Instance B's security group to allow inbound SSH (`22`) only from Instance A's security group.
- Verified that direct SSH from my local machine to Instance B no longer works, while SSH from Instance A to Instance B still works.

## Outcome

Instance A now functions as a bastion host, with Instance B reachable via SSH only through it. This reduces Instance B's exposed attack surface while preserving the deployment workflow.

## Link

[roadmap.sh](https://roadmap.sh/projects/bastion-host)
