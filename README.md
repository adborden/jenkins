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

    $ terraform plan terraform
    $ terraform apply terraform


## Tests

We're using Vagrant for testing/development.

    $ make test

Or work with a single instance

    $ vagrant up <group-name>

You can ssh into the instance to debug.

    $ vagrant ssh <group-name>

When you're done, or if you want to start from scratch, destroy the instance.

    $ vagrant destroy


## Notes

There is a bit of a cyclical dependency between Terraform and Ansible. Ansible
needs the EFS DNS name to setup the mount point. This doesn't exist until
Terraform creates the EFS. Once Terraform creates it, set it as a variable for
Ansible.

You can create the EFS first.

    $ terraform plan terraform -target aws_efs_file_system.jenkins
    $ terraform apply terraform -target aws_efs_file_system.jenkins
    ...
    Outputs:

    jenkins_efs_dns_name = fs-0817f111.efs.us-west-1.amazonaws.com

Then update the variable in `ansible/group_vars/jenkins/vars.yml` and build
a new AMI.

    $ make build

Now we can build the whole thing.

    $ terraform plan terraform
    $ terraform apply terraform


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


### EFS uid/gids

If the jenkins uid/gid changes, the data on the EFS will need to be updated.
Should this be automated as part of the machine startup?

    $ sudo chown -R jenkins:jenkins /mnt/jenkins


### ELB health check

Out of the box, Jenkins fails the ELB health check. The ELB expects a `200` from
`/`, but Jenkins is configured to `403` and redirect to login. Not sure if there
is a better health check endpoint for Jenkins. I just configured read-only
access for anonymous users, since the intention is for jobs to be public by
default.
