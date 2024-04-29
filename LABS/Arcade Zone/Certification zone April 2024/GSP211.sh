#!/bin/bash

#Multiple VPC Networks

#variables 

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export US_REGION=us-west1
export US_REGION2=us-west1-c
export EU_REGION=europe-west4
export US_ZONE=



#Create the managementnet network
gcloud compute networks create managementnet --subnet-mode=custom
gcloud compute networks subnets create managementsubnet-us --network=managementnet --region=$US_REGION --range=10.130.0.0/20


#Create the privatenet network
gcloud compute networks create privatenet --subnet-mode=custom
gcloud compute networks subnets create privatesubnet-us --network=privatenet --region=$US_REGION --range=172.16.0.0/24
gcloud compute networks subnets create privatesubnet-eu --network=privatenet --region=$EU_REGION --range=172.20.0.0/20

#Run the following command to list the available VPC nets and subnets
gcloud compute networks list
gcloud compute networks subnets list --sort-by=NETWORK

#Create the firewall rules for managementnet
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=managementnet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

#Create the firewall rules for privatenet
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

#Run the following command to list all the firewall rules (sorted by VPC network):
gcloud compute firewall-rules list --sort-by=NETWORK

#Task 2. Create VM instances
#Create the managementnet-us-vm instance

gcloud compute instances create managementnet-us-vm --zone=$US_ZONE --machine-type=e2-micro --subnet=managementsubnet-us
#Create the privatenet-us-vm instance
gcloud compute instances create privatenet-us-vm --zone=$US_ZONE --machine-type=e2-micro --subnet=privatesubnet-us

#Task 4. Create a VM instance with multiple network interfaces
#Create the VM instance with multiple network interfaces
gcloud compute instances create vm-appliance --zone=$US_ZONE --machine-type=e2-standard-4 --network-interface network=privatenet,subnet=privatesubnet-us --network-interface network=managementnet,subnet=managementsubnet-us --network-interface network=mynetwork,subnet=mynetwork

#Run the following command to list all the VM instances (sorted by zone):
gcloud compute instances list --sort-by=ZONE

#Task 3. Explore the connectivity between VM instances
#Ping the external IP addresses

INSTANCE_NAMES=("mynet-eu-vm" "managementnet-us-vm" "privatenet-us-vm")

#Functions to retrieve IP address per instance
get_external_ip() {
    local instance_name="$1"
    gcloud compute instances list --filter=name:$instance_name --format='value(EXTERNAL_IP)'
}

get_internal_ip() {
    local instance_name="$1"
    gcloud compute instances list --filter=name:$instance_name --format='value(INTERNAL_IP)'
}

#Explore the network interface connectivity -EXTERNAL IP
for instance in "${INSTANCE_NAMES[@]}"; do
    EXTERNAL_IP=$(get_external_ip "$instance")
    if [ -n "$EXTERNAL_IP" ]; then
        echo "External IP address of $instance: $EXTERNAL_IP"
        gcloud compute ssh mynet-us-vm --strict-host-key-checking="no" --zone=$ZONE --command="ping -c 3 $EXTERNAL_IP && exit" 
    else
        echo "Error: Unable to retrieve IP address for $instance"
    fi
done

#ping -c 3 $(gcloud compute instances list --filter=name:mynet-eu-vm --format='value(EXTERNAL_IP)')
#ping -c 3 $(gcloud compute instances list --filter=name:managementnet-us-vm --format='value(EXTERNAL_IP)')
#ping -c 3 $(gcloud compute instances list --filter=name:privatenet-us-vm --format='value(EXTERNAL_IP)')
#
gcloud compute ssh vm-appliance --strict-host-key-checking="no" --zone $ZONE --command="sudo ifconfig && ip route && exit" 

#Explore the network interface connectivity-INTERNAL IP
for instance in "${INSTANCE_NAMES[@]}"; do
    INTERNAL_IP=$(get_internal_ip "$instance")
    if [ -n "$INTERNAL_IP" ]; then
        echo "External IP address of $instance: $INTERNAL_IP"
        gcloud compute ssh vm-appliance --strict-host-key-checking="no" --zone=$ZONE --command="ping -c 3 $INTERNAL_IP && exit" 
    else
        echo "Error: Unable to retrieve IP address for $instance"
    fi
done





