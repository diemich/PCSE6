#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

#Cloud Monitoring: Qwik Start
#GSP089

# Objectives
# In this lab, you learn how to:
# Monitor a Compute Engine virtual machine (VM) instance with Cloud Monitoring.
# Install monitoring and logging agents for your VM

source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

#VARIABLES
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)

