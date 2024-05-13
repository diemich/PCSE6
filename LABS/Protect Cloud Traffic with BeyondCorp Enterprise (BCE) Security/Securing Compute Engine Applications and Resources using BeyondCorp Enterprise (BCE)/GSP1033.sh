#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

#Build a Secure Google Cloud Network: Challenge Lab
#GSP322
source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

#VARIABLES
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)


#ask 1: Create a Compute Engine template

gcloud beta compute instance-templates create instance-template-20240513-073446 \
--project=qwiklabs-gcp-00-cf7559d249a6 \
--machine-type=e2-micro \
--network-interface=network=default,network-tier=PREMIUM \
--instance-template-region=us-west1 \
--metadata=^,@^startup-script=\#\ Copyright\ 2021\ Google\ LLC$'\n'\#$'\n'\#\ Licensed\ under\ the\ Apache\ License,\ Version\ 2.0\ \(the\ \"License\"\)\;$'\n'\#\ you\ may\ not\ use\ this\ file\ except\ in\ compliance\ with\ the\ License.\#\ You\ may\ obtain\ a\ copy\ of\ the\ License\ at$'\n'\#$'\n'\#\ http://www.apache.org/licenses/LICENSE-2.0$'\n'\#$'\n'\#\ Unless\ required\ by\ applicable\ law\ or\ agreed\ to\ in\ writing,\ software$'\n'\#\ distributed\ under\ the\ License\ is\ distributed\ on\ an\ \"AS\ IS\"\ BASIS,$'\n'\#\ WITHOUT\ WARRANTIES\ OR\ CONDITIONS\ OF\ ANY\ KIND,\ either\ express\ or\ implied.$'\n'\#\ See\ the\ License\ for\ the\ specific\ language\ governing\ permissions\ and$'\n'\#\ limitations\ under\ the\ License.$'\n'$'\n'apt-get\ -y\ update$'\n'apt-get\ -y\ install\ git$'\n'apt-get\ -y\ install\ virtualenv$'\n'git\ clone\ --depth\ 1\ https://github.com/GoogleCloudPlatform/python-docs-samples$'\n'cd\ python-docs-samples/iap$'\n'virtualenv\ venv\ -p\ python3$'\n'source\ venv/bin/activate$'\n'pip\ install\ -r\ requirements.txt$'\n'cat\ example_gce_backend.py\ \|$'\n'sed\ -e\ \"s/YOUR_BACKEND_SERVICE_ID/\$\(gcloud\ compute\ backend-services\ describe\ my-backend-service\ --global--format=\"value\(id\)\"\)/g\"\ \|$'\n'\ \ \ \ sed\ -e\ \"s/YOUR_PROJECT_ID/\$\(gcloud\ config\ get-value\ project\ \|\ tr\ -cd\ \"\[0-9\]\"\)/g\"\ \>\ real_backend.py$'\n'gunicorn\ real_backend:app\ -b\ 0.0.0.0:80,@enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=984429252228-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_only --tags=http-server,https-server --create-disk=auto-delete=yes,boot=yes,device-name=instance-template-20240513-073446,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240415,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any


gcloud beta compute health-checks create http my-health-check \
--project=qwiklabs-gcp-00-cf7559d249a6 \
--port=80 \
--request-path=/ \
--proxy-header=NONE \
--no-enable-logging \
--check-interval=5 \
--timeout=5 \
--unhealthy-threshold=2 \
--healthy-threshold=2


#Task 3: Create a Managed Instance Group
gcloud beta compute instance-groups managed create my-managed-instance-group \
--project=qwiklabs-gcp-00-cf7559d249a6 \
--base-instance-name=my-managed-instance-group \
--template=projects/qwiklabs-gcp-00-cf7559d249a6/regions/us-west1/instanceTemplates/instance-template-20240513-073446 \
--size=1 \
--zone=us-west1-b \
--default-action-on-vm-failure=repair \
--health-check=projects/qwiklabs-gcp-00-cf7559d249a6/global/healthChecks/my-health-check \
--initial-delay=300 \
--no-force-update-on-repair \
--standby-policy-mode=manual \
--list-managed-instances-results=PAGELESS

gcloud beta compute instance-groups managed set-autoscaling my-managed-instance-group \
--project=qwiklabs-gcp-00-cf7559d249a6 --zone=us-west1-b --mode=off --min-num-replicas=1 --max-num-replicas=10 --target-cpu-utilization=0.6 --cool-down-period=60

#Task 4: Get a domain name and certificate
#Step 1: Create a private key and certificate

#You can create a new private key with RSA-2048 encryption in the PEM format using the following OpenSSL command.
openssl genrsa -out PRIVATE_KEY_FILE 2048

#Create an OpenSSL configuration file. When you create an SSL config file, name the file ssl_config and use the following configuration.

#Run the following OpenSSL command to create a certificate signing request (CSR) file.
openssl req -new -key PRIVATE_KEY_FILE \
 -out CSR_FILE \
 -config ssl_config

#If you manage your own CA, or if you want to create a self-signed certificate for testing, you can use the following OpenSSL command:
openssl x509 -req \
 -signkey PRIVATE_KEY_FILE \
 -in CSR_FILE \
 -out CERTIFICATE_FILE.pem \
 -extfile ssl_config \
 -extensions extension_requirements \
 -days 365


#Step 2: Create a self-managed SSL certificate resource
gcloud compute ssl-certificates create my-cert \
 --certificate=CERTIFICATE_FILE.pem \
 --private-key=PRIVATE_KEY_FILE \
 --global




gcloud beta compute instance-groups managed rolling-action start-update my-managed-instance-group --project=qwiklabs-gcp-00-cf7559d249a6 --type='proactive' --max-unavailable=3 --min-ready=0 --minimal-action='restart' --replacement-method='substitute' --version=template=https://www.googleapis.com/compute/beta/projects/qwiklabs-gcp-00-cf7559d249a6/regions/us-west1/instanceTemplates/instance-template-20240513-073446 --zone=us-west1-b



gcloud compute --project=qwiklabs-gcp-00-cf7559d249a6 firewall-rules create allow-iap-traffic --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80,tcp:78 --source-ranges=130.211.0.0/22,35.191.0.0/16

