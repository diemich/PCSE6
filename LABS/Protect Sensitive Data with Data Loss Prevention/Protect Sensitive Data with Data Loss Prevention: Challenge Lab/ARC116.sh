

#Task 1. Redact sensitive data from text content

export BUCKET_NAME=qwiklabs-gcp-04-c6c70d455261-redact

curl -s \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/content:deidentify \
  -d @redact-request.json -o redact-response.txt

gsutil cp redact-response.txt gs://$BUCKET_NAME