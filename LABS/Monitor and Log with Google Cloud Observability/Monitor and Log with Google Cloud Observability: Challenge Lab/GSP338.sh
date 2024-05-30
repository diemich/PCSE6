#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

#source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

#VARIABLES
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)
export METRICS_NAME=large_video_upload_rate
export ALERT=


#Task 1. Configure Cloud Monitoring
gcloud services enable monitoring --project=$PROJECT_ID

#Task 2. Configure a Compute Instance to generate Custom Cloud Monitoring metrics

gcloud compute instances add-metadata video-queue-monitor \
--zone $ZONE \
--metadata  startup-script='#!/bin/bash
ZONE="$ZONE"
REGION="${ZONE%-*}"
PROJECT_ID="$DEVSHELL_PROJECT_ID"

## Install Golang
sudo apt update && sudo apt -y
sudo apt-get install wget -y
sudo apt-get -y install git
sudo chmod 777 /usr/local/
sudo wget https://go.dev/dl/go1.19.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.6.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install ops agent 
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo service google-cloud-ops-agent start

# Create go working directory and add go path
mkdir /work
mkdir /work/go
mkdir /work/go/cache
export GOPATH=/work/go
export GOCACHE=/work/go/cache

# Install Video queue Go source code
cd /work/go
mkdir video
gsutil cp gs://spls/gsp338/video_queue/main.go /work/go/video/main.go

# Get Cloud Monitoring (stackdriver) modules
go get go.opencensus.io
go get contrib.go.opencensus.io/exporter/stackdriver

# Configure env vars for the Video Queue processing application
export MY_PROJECT_ID="$DEVSHELL_PROJECT_ID"
export MY_GCE_INSTANCE_ID="$instance_id"
export MY_GCE_INSTANCE_ZONE="$ZONE"

# Initialize and run the Go application
cd /work
go mod init go/video/main
go mod tidy
go run /work/go/video/main.go' 

gcloud compute instances reset video-queue-monitor --zone $ZONE

#Task 3. Create a custom metric using Cloud Operations logging events

gcloud logging metrics create $METRICS_NAME \
   --description="Metric for hello-app errors" \
   --log-filter='textPayload: "file_format: ([4,8]K).*"'