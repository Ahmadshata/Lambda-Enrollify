variable "secrets" {
  type = map(string)
  sensitive = true
}

variable "secret-name" {
  type = string
}