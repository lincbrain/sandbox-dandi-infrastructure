output "girder_smtp_host" {
  value = module.girder_smtp.host
}
output "girder_smtp_port" {
  value = module.girder_smtp.port
}
output "girder_smtp_username" {
  value = module.girder_smtp.username
}
output "girder_smtp_password" {
  value     = module.girder_smtp.password
  sensitive = true
}
