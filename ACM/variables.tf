variable "domain-name" {
  type = string
}

variable "validation-method" {
  type = string
}

variable "existing-public-route53-zone-name" {
  type = string
}

variable "allow-overwrite" {
  type = bool
  default = false
}