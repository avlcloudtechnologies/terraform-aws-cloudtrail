variable "tags" {
  description = "A map of tags to assign to resources."

  type = map(string)
  default = {
    Terraform = true
  }
}

variable "name" {
  description = "The namespace to be used on all resources."
  type        = string
}

variable "environment" {
  description = "The environement name resources are deployed in."
  type        = string
}