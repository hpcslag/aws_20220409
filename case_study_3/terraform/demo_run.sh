set -e

sleep 1200

terraform init

terraform plan -var-file=staging.tfvars 

terraform apply -auto-approve -var-file=staging.tfvars

sleep 5

./output.sh

url="$(terraform output -raw git_repository_path)"

cd ../ansible
ansible-playbook -v my_server.yml --tags=install

cd ../my_repository/
git init
git checkout -b staging
git add --all
git commit -m "test commit"


git remote add origin "$url"
git push -u origin staging

rm -rf ./.git
cd ../terraform

echo "remind that the port is 8080"