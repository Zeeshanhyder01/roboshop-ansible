#!/bin/bash

##### Change these values ###
ZONE_ID="Z03519863VAIBFYR20RWT"
SG_NAME="MSG-ZEESHAN"
IAM_INSTANCE_PROFILE="Arn=arn:aws:iam::085894364751:instance-profile/role-for-secret-manger-readonly-roboshop-components"
#############################

if [ -z "${1}" ] ; then
  ENV=""
else
  ENV="-$1"
fi
COMPONENT=all
create_ec2() {
  PRIVATE_IP=$(aws ec2 run-instances \
      --image-id ${AMI_ID} \
      --instance-type t2.micro \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}${ENV}}, {Key=Monitor,Value=yes}]" \
      --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}"\
      --security-group-ids ${SGID} \
      --iam-instance-profile="${IAM_INSTANCE_PROFILE}" \
      | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

  sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}${ENV}/" route53.json >/tmp/records.json
  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/records.json
}

#AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" | jq '.Images[].ImageId' | sed -e 's/"//g')
AMI_ID="ami-0b618b7be3534c792"
SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${SG_NAME} | jq  '.SecurityGroups[].GroupId' | sed -e 's/"//g')

if [ "$COMPONENT" == "all" ]; then
  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq redis ; do
    COMPONENT=$component
    create_ec2
  done
else
  create_ec2
fi

