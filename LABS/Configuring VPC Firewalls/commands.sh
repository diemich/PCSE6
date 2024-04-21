#!/bin/bash

#Configuring VPC Firewalls

#To create the network mynetwork with auto subnets, run the following command:
gcloud compute networks create mynetwork --subnet-mode=auto

#To create the network privatenet with custom subnets, run the following command
gcloud compute networks create privatenet \
--subnet-mode=custom

#To create a custom subnet in the privatenet network, run the following command:
gcloud compute networks subnets create privatesubnet \
--network=privatenet --region=us-central1 \
--range=10.0.0.0/24 --enable-private-ip-google-access

#To create some instances to use later for testing in all networks, run these commands:

gcloud compute instances create default-us-vm \
--machine-type e2-micro \
--zone=us-central1-a --network=default

gcloud compute instances create mynet-us-vm \
--machine-type e2-micro \
--zone=us-central1-a --network=mynetwork

gcloud compute instances create mynet-eu-vm \
--machine-type e2-micro \
--zone=europe-west1-b --network=mynetwork

gcloud compute instances create privatenet-bastion \
--machine-type e2-micro \
--zone=us-central1-c --subnet=privatesubnet --can-ip-forward

gcloud compute instances create privatenet-us-vm \
--machine-type e2-micro \
--zone=us-central1-f --subnet=privatesubnet

#gcloud compute networks list  
gcloud compute networks list  
gcloud compute networks subnets list 
gcloud compute networks subnets list --network default


gcloud compute firewall-rules list

gcloud compute firewall-rules list --format="table(
        name,
        network,
        direction,
        priority,
        sourceRanges.list():label=SRC_RANGES,
        destinationRanges.list():label=DEST_RANGES,
        allowed[].map().firewall_rule().list():label=ALLOW,
        denied[].map().firewall_rule().list():label=DENY,
        sourceTags.list():label=SRC_TAGS,
        sourceServiceAccounts.list():label=SRC_SVC_ACCT,
        targetTags.list():label=TARGET_TAGS,
        targetServiceAccounts.list():label=TARGET_SVC_ACCT,
        disabled
    )"



gcloud compute instances list 

#SSH to the default-us-vm instance 
gcloud compute ssh default-us-vm --zone="us-central1-a"


gcloud compute instances delete default-us-vm --zone="us-central1-a"

#Allow SSH access from Cloud Shell
ip=$(curl -s https://api.ipify.org)
echo "My External IP address is: $ip"

#To add a firewall rule that allows port 22 (SSH) traffic from the Cloud Shell IP address, run the following command:
gcloud compute firewall-rules create \
mynetwork-ingress-allow-ssh-from-cs \
--network mynetwork --action ALLOW --direction INGRESS \
--rules tcp:22 --source-ranges $ip --target-tags=lab-ssh

#To add the lab-ssh network tag to the mynet-eu-vm and mynet-us-vm instances, run the following commands:

gcloud compute instances add-tags mynet-eu-vm \
    --zone europe-west1-b \
    --tags lab-ssh
gcloud compute instances add-tags mynet-us-vm \
    --zone us-central1-a \
    --tags lab-ssh

 #To ssh into the mynet-eu-vm instance, run the following commans:
gcloud compute ssh qwiklabs@mynet-eu-vm --zone europe-west1-b 

gcloud compute ssh qwiklabs@mynet-us-vm --zone us-central1-a

#To add a firewall rule that allows ALL instances in the mynetwork VPC to ping each other, run the following command:
gcloud compute firewall-rules create \
mynetwork-ingress-allow-icmp-internal --network \
mynetwork --action ALLOW --direction INGRESS --rules icmp \
--source-ranges 10.128.0.0/9


#
gcloud compute firewall-rules create \
mynetwork-ingress-deny-icmp-all --network \
mynetwork --action DENY --direction INGRESS --rules icmp \
--priority 500



 ping mynet-eu-vm.europe-west1-b.c.qwiklabs-gcp-03-9091bcae2b4a.internal

 gcloud compute firewall-rules update \
mynetwork-ingress-deny-icmp-all \
--priority 2000

gcloud compute firewall-rules list \
--filter="network:mynetwork"

#Create a firewall egress rule to block ICMP traffic from any IP with a priority of 10000:
gcloud compute firewall-rules create \
mynetwork-egress-deny-icmp-all --network \
mynetwork --action DENY --direction EGRESS --rules icmp \
--priority 10000