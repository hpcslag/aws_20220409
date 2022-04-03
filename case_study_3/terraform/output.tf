output "my_servers" {
    value = [{
        public_ip = module.my_server.public_ip
        namespace = module.my_server.namespace
    }]
}
