set -e

terraform init

terraform plan -var-file=staging.tfvars 

terraform apply -auto-approve -var-file=staging.tfvars