#!bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0e46ce6da86ce403e" # replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
DOMAIN_NAME="njanapati.site" # replace with your domain

for instance in ${INSTANCES[@]}
#or instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0e46ce6da86ce403e --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)   # this command will create an instance and generates an instance_id
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi
    echo "$instance IP address: $IP"
    sh /home/ec2-user/shell-roboshop/route53.sh "$RECORD_NAME" "$IP" "$instance"
done