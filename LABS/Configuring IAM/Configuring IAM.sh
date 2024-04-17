#https://www.cloudskillsboost.google/course_templates/21/labs/449936

#Configuring IAM

#create a variable with the project name
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)




gcloud storage cp sample.txt gs://$PROJECT_ID

gcloud iam roles create app_viewer --project \\$PROJECT_ID --file role.yaml

gcloud iam roles list --project $PROJECT_ID

gcloud iam roles describe app_viewer --project \\$PROJECT_ID

gcloud iam roles update app_viewer --project \\$PROJECT_ID --file update-role.yaml
gcloud iam roles update app_viewer --project \\$PROJECT_ID --stage DISABLED
gcloud iam roles delete app_viewer --project \\$PROJECT_ID
gcloud iam roles list --project $PROJECT_ID
gcloud iam roles list --project $PROJECT_ID \\--show-deleted

gcloud iam roles undelete app_viewer --project \\$PROJECT_ID
gcloud iam roles list --project $PROJECT_ID



