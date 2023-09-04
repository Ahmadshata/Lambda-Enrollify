
output "custom-domain-invoke-url" {
  value = "https://${module.enrollment-api.custom-domain-name}/${module.enrollment-api.resource-name}"
}