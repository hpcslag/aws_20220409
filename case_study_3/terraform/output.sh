set -e

terraform refresh -var-file=staging.tfvars

terraform output -json my_servers | jq -r '.[] | "Host \(.namespace)
    Hostname \(.public_ip)
    User ubuntu
    IdentityFile ~/.ssh/id_rsa"' >> ssh.config

echo "[my_servers]" >> hosts
terraform output -json my_servers | jq -r '.[] | "\(.namespace)"' >> hosts

mv ./ssh.config ../ansible/ssh.config

mv ./hosts ../ansible/hosts