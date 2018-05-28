variable "web_instances_desired" {
  type = "string"
  description = "Desired number of jenkins-web instances to scale."
  default = "1"
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
