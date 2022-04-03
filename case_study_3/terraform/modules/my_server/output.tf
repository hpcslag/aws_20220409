output "public_ip" {
  value       = aws_instance._.public_ip
}

output "namespace" {
  value       = aws_instance._.tags.Name
}