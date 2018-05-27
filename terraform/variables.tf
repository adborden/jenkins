variable "env" {
  description = "The environment this infrastructure is a part of."
  default     = "development"
}

variable "domain_prefix" {
  description = "The prefix for the domain."
  default     = "jenkins-dev"
}

variable "web_instances_desired" {
  type = "string"
  description = "Desired number of jenkins-web instances to scale."
  default = "2"
}

variable "web_instances_min" {
  type = "string"
  description = "Minimum number of jenkins-web instances to scale."
  default = "1"
}

variable "web_instances_max" {
  type = "string"
  description = "Maximum number of jenkins-web instances to scale."
  default = "4"
}
