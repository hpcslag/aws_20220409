output "public_ip" {
  value       = aws_instance._.public_ip
}

output "namespace" {
  value       = aws_instance._.tags.Name
}

output "demo_servers" {
  value = [
        {
            public_ip = aws_instance._.public_ip
            namespace = aws_instance._.tags.Name
        }
    ]
}