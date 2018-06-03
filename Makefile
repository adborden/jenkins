ifeq ($(BRANCH_NAME), master)
  VARIABLES += -var env=production
  TF_VARFILE = -var-file=production.tfvars
  TF_WORKSPACE=production
endif

check:
	packer validate -var ansible_group=jenkins-web packer/*.json
	terraform validate terraform
	ansible-playbook --syntax-check ansible/*.yml

init:
	terraform init terraform

test:
	$(MAKE) check
	vagrant up --no-provision
	vagrant provision

plan:
	TF_WORKSPACE=$(TF_WORKSPACE) terraform plan $(TF_VARFILE) $(VARIABLES) -out=plan.tfplan terraform

apply: plan.tfplan
	TF_WORKSPACE=$(TF_WORKSPACE) terraform apply plan.tfplan
	rm plan.tfplan

build:
	packer build $(VARIABLES) -var ansible_group=jenkins-web packer/jenkins.json
	packer build $(VARIABLES) -var ansible_group=jenkins-worker packer/jenkins.json

.PHONY = apply build check init plan test
