variable "api-name" {
  type = string
}

variable "api-type" {
  type = list(string)
}

variable "resource-name" {
  type = string
}

variable "authorizer-name" {
  type = string
}

variable "stage-name" {
  type = string
}

variable "custom-domain-name" {
  type = string
}

variable "evaluate-target-health" {
  type = bool
}

variable "auth-fun-invoke-arn" {
  type = string
}
variable "manipulator-fun-invoke-arn" {
  type = string
}

variable "certificate-arn" {
  type = string
}

variable "zone-id" {
  type = string
}