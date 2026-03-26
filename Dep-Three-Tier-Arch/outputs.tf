output "db_password" {
  value = module.database-module.db_config.password
  sensitive = true
}

output "lb_dns_name" {
  value = module.autoscaling-module.lb_dns_name
}

