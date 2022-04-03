namespace="my_server_staging"
aws_region="us-east-2"
instance_type="t2.micro"
# 30gb
volume_size=30
vpc_cidr_prefix16="10.1"
ec2_ami="ami-0b29b6e62f2343b46"

# key-pair: better create outside.
key_name="username"
# run: ssh-keygen
deployer_key="ssh-rsa ....."

availability_zone_1 = "us-east-2a"
availability_zone_2 = "us-east-2c"

# 注意，要加上自己家的 ip/32 不然就要用 0.0.0.0/0
allow_traffic_cidrs = [ "0.0.0.0/0" ]
deployment_group_name="my_deployment_group"