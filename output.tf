
output "custom-domain-invoke-url" {
  value = "https://${module.enrollment-api.custom-domain-name}/${module.enrollment-api.resource-name}"
}
output "api-key-value" {
  value = "x-api-key: ${module.enrollment-api.api-key-value}"
}