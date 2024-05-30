#!/bin/bash
set -euxo pipefail #Bash Strict Mode
#IFS=$'\n\t' #Internal Field Separator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence.

#Data Loss Prevention: Qwik Start - JSON
#GSP107

#In this lab, you set up a JSON file to analyze, send it to the Data Loss Prevention API, to inspect a string of data for sensitive information, then redact any sensitive information that was found.


source "$HOME/PCSE6/LABS/GCP_library.sh" #Library call to reuse commands 

#VARIABLES
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export ZONE=$(gcloud config get compute/zone)
export REGION=$(gcloud config get compute/region)

gcloud auth application-default login --no-launch-browser

gcloud auth print-access-token





curl -s \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect \
  -d @inspect-request.json -o inspect-output.txt


curl -s \
-H "Authorization: Bearer ya29.a0AXooCgu_3IuwXvwlPQKuFBOUV7ETubeDcBRO2gtIFYNB9LSIENghnx_gh23t8ujE9qWIZJ8k33gu5oQ0gKMLTgIjY_hXD52gUmAqhWRzPGVS0zjE0Jj1SdExSBaM5o8BUiCp1rInP87B-qHcYCvkA84drST_XXP3MAQcaCgYKAYQSARASFQHGX2MitWn21EpQ9HYX_ma5270BDA0171" \
-H "Content-Type: application/json" \
https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect \
-d @inspect-request.json -o inspect-output.txt