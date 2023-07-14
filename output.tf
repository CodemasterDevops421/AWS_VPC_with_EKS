output "public_ip_of_kubectl_server" {
  description = "Public IP of demo server"
  value       = aws_instance.kubectl-server[*].public_ip
}

output "private_ip_of_demo_server" {
  description = "Private IP of demo server"
  value       = aws_instance.kubectl-server[*].private_ip
}
