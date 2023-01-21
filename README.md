# Jenkins CI/CD

Experimental Jenkins CI server on AWS with continuous self-delivery.

Contains ansible playbooks, packer template, and terraform configuration files
to deploy a Jenkins cluster in a semi- high availability mode. HA is the goal,
but Jenkins is not really designed for true HA.

The production environment (jenkins.aws.adborden.net) is configured to watch
this repository. All changes are linted. Changes to the `develop` branch are
deployed to a development environment (jenkins-dev.aws.adborden.net). Changes to
`master` are deployed to the production environment (production deploys itself).


## Prerequisites

- Packer
- Terraform
- Python 3.6
- [pipenv](https://docs.pipenv.org/en/latest/)


## Setup

Install python dependencies.

    $ pipenv install

Initialize Terraform.

    $ terraform init terraform

Run the build.

    $ make build

Deploy the infrastructure.

    $ make plan
    $ make apply


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

Then update the variable in `ansible/roles/jenkins-web/vars/<env>.yml` and build
a new AMI.

    $ make build

_At this point, you probably want to spin up a one-off instance with the new AMI
to initialize the Jenkins state._

Now we can build the whole thing.

    $ terraform plan terraform
    $ terraform apply terraform


## Initial Jenkins state creation

Initially, the EFS is created with root permissions 750, so the jenkins-web
instances cannot write to it. You'll need to ssh into the instance manually, set
the permissions, then enter the security token into the web UI. Alternatively,
you can copy an existing Jenkins state and update the permissions to
`jenkins:jenkins`.

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


### Rotating new AMIs

Autoscaling groups won't automatically rotate instances needing new AMIs.
Instead this can be done by forcing re-creation of the ASG. Probably adding an
AMI version variable and making that part of the ASG name would work best (the
change in name would trigger re-creation).


## Todo

- [ ] Avoid ASG for workers, using DNS would mean the configuration in jenkins
  does not need to change.
- [ ] Add backup/restore strategy.
- [ ] Keep secrets (SSH key) out of AMI.
- [ ] Are there better tests we can automate on CI? Maybe with vagrant?
- [ ] Only build AMIs when dependencies change.
- [ ] Figure out the right directory structure for terraform files. Is `cd` necessary?
- [ ] Move terraform files into module.
- [ ] Maybe don't use autoscaling groups. You get better control to roll new
  instances with terraform + `create_before_destroy` as well as configuring IPs
  of workers. The goal is not really dynamic scaling.
