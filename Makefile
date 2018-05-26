
test:
	packer validate *.json
	ansible-playbook --syntax-check ansible/*.yml

build:
	packer build *.json
