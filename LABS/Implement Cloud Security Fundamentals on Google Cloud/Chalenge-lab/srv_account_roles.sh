#!/bin/bash

# Define the service account email, change the xxxxx

DEVSHELL_PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
SRV_ACCOUNT_NAME="orca-private-cluster-922-sa"
SERVICE_ACCOUNT_EMAIL="${SRV_ACCOUNT_NAME}@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com"

# Define the roles that you want in an array
roles=(
    "projects/${DEVSHELL_PROJECT_ID}/roles/${SRV_ACCOUNT_NAME}"
    "roles/iam.serviceAccountUser"
    "roles/monitoring.viewer"
    "roles/monitoring.metricWriter"
    "roles/logging.logWriter"
)

# Loop through each role and assign it to the service account
for role in "${roles[@]}"; do
    gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_EMAIL \
        --role="$role" \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL"
done