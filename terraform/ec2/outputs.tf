output "instance_public_ip" {
  value       = aws_instance.builder.public_ip
  description = "Public IP of the EC2 instance"
}

output "ssh_private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to the generated private SSH key"
  sensitive   = true
}

output "security_group_id" {
  value       = aws_security_group.builder_sg.id
  description = "ID of the security group"
}
