output "my_servers" {
    value = [{
        public_ip = module.my_server.public_ip
        namespace = module.my_server.namespace
    }]
}

output "git_repository_path" {
    value = aws_codecommit_repository.my_repository.clone_url_ssh
}