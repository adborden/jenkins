
check:
	packer validate *.json
	terraform validate terraform
	ansible-playbook --syntax-check ansible/*.yml

test:
	$(MAKE) check
	vagrant up --no-provision
	vagrant provision

build:
	packer build *.json
