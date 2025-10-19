output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of EC2 instance"
  value       = aws_instance.app_instance.public_dns
}
