VARIABLES =

ifeq ($(BRANCH_NAME), master)
  VARIABLES += -var env=production
endif

check:
	packer validate *.json
	terraform validate terraform
	ansible-playbook --syntax-check ansible/*.yml

init:
	terraform init terraform

test:
	$(MAKE) check
	vagrant up --no-provision
	vagrant provision

plan:
	terraform plan $(VARIABLES) -out=plan.tfplan terraform

apply: plan.tfplan
	terraform apply plan.tfplan
	rm plan.tfplan

build:
	packer build $(VARIABLES) *.json
