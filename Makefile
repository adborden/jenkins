
check:
	packer validate packer/*.json
	terraform validate terraform
	ansible-playbook --syntax-check ansible/*.yml

init:
	terraform plan -var web_instances_desired=1 -var web_instances_max=1 -out=plan.tfplan terraform

plan:
	terraform plan -out=plan.tfplan terraform
	read -p "Continue? " continue
	if [[ "\${continue}" !== "yes" ]]; then
	  echo Anything other than \"yes\" aborts. >&2
	  rm plan.tfplan
	  exit 1
	fi

apply: plan.tfplan
	terraform apply plan.tfplan
	rm plan.tfplan

test:
	$(MAKE) check
	vagrant up --no-provision
	vagrant provision

build:
	packer build -var ansible_group=jenkins packer/jenkins.json

.PHONY = apply build check init plan test
