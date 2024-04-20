#!/bin/bash

#Implement Cloud Security Fundamentals on Google Cloud: Challenge Lab
#GSP342

#------------Topics tested-----------
#Create a custom security role.
#Create a service account.
#Bind IAM security roles to a service account.
#Create a private Kubernetes Engine cluster in a custom subnet.
#Deploy an application to a private Kubernetes Engine cluster


#The minimum permissions required by the service account that is specified for a Kubernetes Engine cluster is covered by these three built in roles:
#roles/monitoring.viewer
#roles/monitoring.metricWriter
#roles/logging.logWriter

#The service account used by the cluster should have the permissions necessary to add and update objects in Google Cloud Storage buckets.
#To do this you will have to create a new custom IAM role that will provide the following permissions:

#storage.buckets.get
#storage.objects.get
#storage.objects.list
#storage.objects.update
#storage.objects.create

#variable definition 
export DEVSHELL_PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export REGION=$(gcloud config get-value compute/region)
export ZONE=$(gcloud config get-value compute/zone)
export CUSTOM_SEC_ROLE="orca_storage_editor_614"
export SRV_ACCOUNT_NAME="orca-private-cluster-897-sa"
export CLUSTER_NAME="orca-cluster-892"

#Enter the following to display the project IDs for your Google Cloud projects:
gcloud projects list

gcloud config set project $DEVSHELL_PROJECT_ID

#Get a list of services that you can enable in your project:
gcloud services list --available

gcloud services enable $SERVICE_NAME

# Task 1. Create a custom security role
gcloud iam roles create "${CUSTOM_SEC_ROLE}" --project "${DEVSHELL_PROJECT_ID}" --file sec_role_def.yml

gcloud iam roles describe roles/projects/"${DEVSHELL_PROJECT_ID}"/roles/"${CUSTOM_SEC_ROLE}"

# Task 2. Create a service account


    gcloud iam service-accounts create "${SRV_ACCOUNT_NAME}" \
  --description="service account for orca's private cluster" \
  --display-name="${SRV_ACCOUNT_NAME}"

  gcloud iam service-accounts list

  export SERVICE_ACCOUNT="${SRV_ACCOUNT_NAME}@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com"

# Task 3. Bind a custom security role to a service account

gcloud projects add-iam-policy-binding "${DEVSHELL_PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="projects/${DEVSHELL_PROJECT_ID}/roles/${CUSTOM_SEC_ROLE}" \
    --verbosity=debug

    gcloud projects add-iam-policy-binding "${DEVSHELL_PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/monitoring.viewer" 

    gcloud projects add-iam-policy-binding "${DEVSHELL_PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/monitoring.metricWriter" 

    gcloud projects add-iam-policy-binding "${DEVSHELL_PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/logging.logWriter" 

#OPTIONAL

#run script 
#chmod +x srv_account_roles.sh 
#./srv_account_roles.sh 

# Task 4. Create and configure a new Kubernetes Engine private cluster

#list networks and subnets
gcloud compute network list
gcloud compute networks subnets list

#Create a private cluster that uses your subnetwork:
gcloud container clusters create "${CLUSTER_NAME}" \
    --network orca-build-vpc\
    --subnetwork orca-build-subnet \
    --enable-private-nodes \
    --enable-ip-alias \
    --master-ipv4-cidr 172.16.0.16/28 \
    --enable-private-endpoint \
    --service-account "${SERVICE_ACCOUNT}"

#list vm instances

#Once the cluster is configured you must add the internal ip-address of the orca-jumphost compute instance to the master authorized network list
#get the jumphost Internal IP address
gcloud compute instances list 

#
gcloud container clusters update "${CLUSTER_NAME}" \
    --enable-master-authorized-networks \
    --master-authorized-networks 192.168.10.2/32


##
gcloud container clusters describe $CLUSTER_NAME


#Create a source instance which you'll use to check the connectivity to Kubernetes clusters:

gcloud compute instances list


# Task 5. Deploy an application to a private Kubernetes Engine cluster


gcloud compute ssh source-instance --zone=$ZONE

#COMMANDS TO EXECUTE IN ORCA-JUMPHOST
sudo apt install kubectl google-cloud-sdk-gke-gcloud-auth-plugin
echo "export USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> ~/.bashrc
source ~/.bashrc

gcloud container clusters get-credentials orca-cluster-607 --zone=us-east1-d

kubectl get nodes --output wide


#App deployment
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment hello-server --name orca-hello-service --type LoadBalancer --port 80 --target-port 8080






#TROUBLESHOOTING
gcloud iam service-accounts list
gcloud projects get-iam-policy $DEVSHELL_PROJECT_ID
gcloud compute networks subnets list --network default
gcloud compute networks subnets describe [SUBNET_NAME] --region=$REGION