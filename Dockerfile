FROM alpine:3.7

ARG PACKER_VER=1.2.4
ARG TERRAFORM_VER=0.11.7

ENV USER ansible
# Ansible needs to write to the home directory
ENV HOME /tmp

RUN apk --no-cache add ansible ca-certificates jq make openssl sed \
  && wget -O /tmp/packer.zip \
    "https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip" \
  && unzip -o /tmp/packer.zip -d /usr/local/bin \
  && rm -f /tmp/packer.zip \
  && wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip \
  && unzip -o /tmp/terraform.zip -d /usr/local/bin \
  && rm -f /tmp/terraform.zip \
  && apk --no-network del openssl
