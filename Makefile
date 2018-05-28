
check:
	packer validate packer/*.json
	terraform validate terraform
	ansible-playbook --syntax-check ansible/*.yml

init:
	terraform plan -var web_instances_desired=1 -var web_instances_max=1 -out=plan.tfplan terraform

plan:
	terraform plan -out=plan.tfplan terraform

apply: plan.tfplan
	terraform apply plan.tfplan
	rm plan.tfplan

test:
	$(MAKE) check
	vagrant up --no-provision
	vagrant provision

build:
	packer build -var ansible_group=jenkins-web packer/jenkins.json
	packer build -var ansible_group=jenkins-worker packer/jenkins.json

.PHONY = apply build check init plan test
