# EC2 Instance

This project covers the setup of an AWS EC2 instance for hosting and deploying a simple web application. It brings together the infrastructure and access steps from the related projects:

- [SSH Remote Server Setup](../06-ssh-remote-server-setup/README.md) — configuring SSH access, key-based authentication, and secure server connection.
- [Static Site Server](../07-static-site-server/README.md) — installing nginx, serving a static website, and deploying files with rsync.

## Overview

The workflow begins with provisioning an Ubuntu EC2 instance on AWS and connecting to it securely over SSH. Once access is established, the server is prepared for hosting by installing the necessary software and configuring network access for web traffic.

## Key steps

- Launched an Ubuntu EC2 instance with a `t2.micro` instance type, using the default VPC and subnet, and created a security group that allows inbound traffic on ports `22` (SSH) and `80` (HTTP).
- Created an SSH key pair and assigned a public IP address to the instance.
- Connected to the instance over SSH using the private key.
- Updated the system packages and installed a web server such as nginx.
- Created a simple HTML page for the static website and placed it in the web server directory.
- Deployed the website content to the instance and accessed it through the public IP address.

## Outcome

The EC2 instance becomes a usable remote web server, ready to host a simple website and support future infrastructure and deployment tasks.

## Link

[roadmap.sh](https://roadmap.sh/projects/ec2-instance)
