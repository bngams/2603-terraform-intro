output "ec2_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = aws_instance.wp_ec2_instance.public_ip
}

output "wordpress_url" {
  description = "URL d'accès à WordPress"
  value       = "http://${aws_instance.wp_ec2_instance.public_ip}"
}

output "rds_endpoint" {
  description = "Endpoint de la base de données"
  value       = aws_db_instance.wp_rds_instance.endpoint
  sensitive   = true
}

output "db_name" {
  description = "Nom de la base de données WordPress"
  value       = aws_db_instance.wp_rds_instance.db_name
}

output "db_username" {
  description = "Nom d'utilisateur de la base de données"
  value       = aws_db_instance.wp_rds_instance.username
  sensitive   = true
}

output "db_password" {
  description = "Mot de passe de la base de données"
  value       = aws_db_instance.wp_rds_instance.password
  sensitive   = true
}

output "db_host" {
  description = "Hostname de la base de données (sans le port)"
  value       = split(":", aws_db_instance.wp_rds_instance.endpoint)[0]
  sensitive   = true
}