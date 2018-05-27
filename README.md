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


## Tests

We're using Vagrant for testing/development.

    $ make test

You can ssh into the instance to debug.

    $ vagrant ssh

When you're done, or if you want to start from scratch, destroy the instance.

    $ vagrant destroy
