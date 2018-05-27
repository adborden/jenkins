# Jenkins

Jenkins CI server on AWS.


## Prerequisites

- Packer
- Terraform
- Python 3.6


## Setup

Install python dependencies.

    $ pip install -r requirements.txt

Initialize Terraform.

    $ terraform init terraform

Run the build.

    $ make build

Deploy the infrastructure.

    $ terraform apply terraform


## Tests

We're using Vagrant for testing/development.

    $ make test

You can ssh into the instance to debug.

    $ vagrant ssh

When you're done, or if you want to start from scratch, destroy the instance.

    $ vagrant destroy


## Notes

There is a bit of a cyclical dependency between Terraform and Ansible. Ansible
needs the EFS DNS name to setup the mount point. This doesn't exist until
Terraform creates the EFS. Once Terraform creates it, set it as a variable for
Ansible.


## Initial Jenkins state creation

When you initialize Jenkins for the first time there are a few steps. First, you
need to provide a token to the UI. The token is available in the jenkins logs at
`/var/log/jenkins/jenkins.log`. Once that's provided, follow the on-screen
instructions. Initially, you'll want to boot with a single node, otherwise there
might be a race-condition with both nodes writing to the shared storage.

Here are the general steps to take:

1. Start a single web node with a public IP and port 22 available in the
   security group.
1. `terraform apply terraform`


## Quirks

If the jenkins uid/gid changes, the data on the EFS will need to be updated.
Should this be automated as part of the machine startup?

    $ sudo chown -R jenkins:jenkins /mnt/jenkins
