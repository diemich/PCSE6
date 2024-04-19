#!/bin/bash

#Setting up a Private Kubernetes Cluster
#GSP178

DEVSHELL_PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
REGION= $(gcloud config get-value compute/region)
ZONE=$(gcloud config get-value compute/zone)

#gcloud auth application-default login

#Task 1. Set the region and zone
gcloud config set compute/zone us-west1-a

#Create a variable for region:
#export REGION=us-west1

#Create a variable for zone:
#export ZONE=us-west1-a

#Task 2. Creating a private cluster
#When you create a private cluster, you must specify a /28 CIDR range for the VMs that run the Kubernetes master components
# and you need to enable IP aliases.

#Run the following to create the cluster:
gcloud beta container clusters create private-cluster \
    --enable-private-nodes \
    --master-ipv4-cidr 172.16.0.16/28 \
    --enable-ip-alias \
    --create-subnetwork ""

#Task 3. View your subnet and secondary address ranges

#List the subnets in the default network:

gcloud compute networks subnets list --network default

gcloud compute networks subnets list --network default | grep 'gke-private*'


#In the output, find the name of the subnetwork that was automatically created for your cluster.
#For example, gke-private-cluster-subnet-xxxxxxxx. Save the name of the cluster, you'll use it in the next step.

export SUBNETNAME=gke-private-cluster-subnet-716fb066

gcloud compute networks subnets describe "${SUBNETNAME}" --region=$REGION

#Task 4. Enable master authorized networks

#Create a source instance which you'll use to check the connectivity to Kubernetes clusters:
gcloud compute instances create source-instance --zone=$ZONE --scopes 'https://www.googleapis.com/auth/cloud-platform'

#Get the <External_IP> of the source-instance with:

gcloud compute instances describe source-instance --zone=$ZONE | grep natIP

#35.230.27.23

#Run the following to Authorize your external address range, replacing [MY_EXTERNAL_RANGE] with the CIDR range of the external addresses from the previous output (your CIDR range is natIP/32). 
#With CIDR range as natIP/32, we are allowlisting one specific IP address:

export MY_EXTERNAL_RANGE="35.230.27.23/32"
echo $MY_EXTERNAL_RANGE

gcloud container clusters update private-cluster \
    --enable-master-authorized-networks \
    --master-authorized-networks "${MY_EXTERNAL_RANGE}"

#Now that you have access to the master from a range of external addresses, you'll install kubectl so you can use it to get information about your cluster. 
#For example, you can use kubectl to verify that your nodes do not have external IP addresses.   

#SSH into source-instance with:
gcloud compute ssh source-instance --zone=$ZONE

#In SSH shell install kubectl component of Cloud-SDK:
sudo apt-get install kubectl

# Please make sure that the assigned zone has been exported in the ZONE variable
export ZONE="value-for-zone"

sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
gcloud container clusters get-credentials private-cluster --zone=$ZONE

#Verify that your cluster nodes do not have external IP addresses:
kubectl get nodes --output yaml | grep -A4 addresses

#Here is another command you can use to verify that your nodes do not have external IP addresses:
kubectl get nodes --output wide

#Close the SSH 

#Task 5. Clean Up
#Delete the Kubernetes cluster:
gcloud container clusters delete private-cluster --zone=$ZONE

#Task 6. Create a private cluster that uses a custom subnetwork

#In the previous section Kubernetes Engine automatically created a subnetwork for you.
# In this section, you'll create your own custom subnetwork, and then create a private cluster.
# Your subnetwork has a primary address range and two secondary address ranges.

#Create a subnetwork and secondary ranges:

gcloud compute networks subnets create my-subnet \
    --network default \
    --range 10.0.4.0/22 \
    --enable-private-ip-google-access \
    --region=$REGION \
    --secondary-range my-svc-range=10.0.32.0/20,my-pod-range=10.4.0.0/14

#Create a private cluster that uses your subnetwork:
gcloud beta container clusters create private-cluster2 \
    --enable-private-nodes \
    --enable-ip-alias \
    --master-ipv4-cidr 172.16.0.32/28 \
    --subnetwork my-subnet \
    --services-secondary-range-name my-svc-range \
    --cluster-secondary-range-name my-pod-range \
    --zone=$ZONE

#Retrieve the external address range of the source instance:

gcloud compute instances describe source-instance --zone=$ZONE | grep natIP

#Run the following to Authorize your external address range, replacing [MY_EXTERNAL_RANGE] with the CIDR range of the external addresses 
#from the previous output (your CIDR range is natIP/32). With CIDR range as natIP/32, 
#we are allowlisting one specific IP address:

gcloud container clusters update private-cluster2 \
    --enable-master-authorized-networks \
    --zone=$ZONE \
    --master-authorized-networks "${MY_EXTERNAL_RANGE}"

#SSH into source-instance with:

gcloud compute ssh source-instance --zone=$ZONE
