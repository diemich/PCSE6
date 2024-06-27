#!/bin/bash
set -euxo pipefail #Bash Strict Mode

#delete VMS
gcloud compute instances delete -q us-client-vm --zone us-central1-c

gcloud compute instances delete -q us-web-vm --zone us-central1-c

gcloud compute instances delete -q europe-client-vm --zone europe-west1-c

gcloud compute instances delete -q europe-web-vm --zone europe-west1-c

gcloud compute instances delete -q asia-client-vm --zone asia-southeast1-a

#delete FW rules
gcloud compute firewall-rules delete -q allow-http-traffic

gcloud compute firewall-rules delete fw-default-iapproxy

#delete record set
gcloud dns record-sets delete geo.example.com --type=A --zone=example

#delete private zone
gcloud dns managed-zones delete example