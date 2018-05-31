variable "env" {
  description = "The environment this infrastructure is a part of."
  default     = "development"
}

variable "domain_prefix" {
  description = "The prefix for the domain."
  default     = "jenkins-dev"
}
