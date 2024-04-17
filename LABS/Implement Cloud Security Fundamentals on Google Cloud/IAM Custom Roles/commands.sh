#!/bin/bash
export DEVSHELL_PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)

#set region 
#gcloud config set compute/region us-east4

#Task 1. View the available permissions for a resource
#Run the following to get the list of permissions available for your project.:
gcloud iam list-testable-permissions //cloudresourcemanager.googleapis.com/projects/$DEVSHELL_PROJECT_ID

#Task 2. Get the role metadata
#To view the role metadata, use command below, replacing [ROLE_NAME] with the role. 
#For example: roles/viewer or roles/editor:
gcloud iam roles describe [ROLE_NAME]

#Task 3. View the grantable roles on resources
gcloud iam list-grantable-roles //cloudresourcemanager.googleapis.com/projects/$DEVSHELL_PROJECT_ID

#Task 4. Create a custom role using a YAML file
gcloud iam roles create editor --project $DEVSHELL_PROJECT_ID \\n--file role-definition.yaml

#Task 5. Create a custom role using flags
gcloud iam roles create viewer --project $DEVSHELL_PROJECT_ID \
--title "Role Viewer" --description "Custom role description." \
--permissions compute.instances.get,compute.instances.list --stage ALPHA

#Task 6. List the custom roles
gcloud iam roles list --project $DEVSHELL_PROJECT_ID

gcloud iam roles list


#Task 7. Update a custom role using a YAML file
gcloud iam roles describe editor --project $DEVSHELL_PROJECT_ID >> new-role-definition.yaml

gcloud iam roles update editor --project $DEVSHELL_PROJECT_ID \
--file new-role-definition.yaml

#Task 8. Update a custom role using flags
#Execute the following gcloud command to add permissions to the viewer role using flags:
gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--add-permissions storage.buckets.get,storage.buckets.list

#Task 9. Disable a custom role
gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--stage DISABLED

#Task 10. Delete a custom role
#Use the gcloud iam roles delete command to delete a custom role. 
#Once deleted the role is inactive and cannot be used to create new IAM policy bindings:

gcloud iam roles delete viewer --project $DEVSHELL_PROJECT_ID


#Task 11. Restore a custom role
#Within the 7 days window you can restore a role. Deleted roles are in a DISABLED state. 
#To make it available again, update the --stage flag:

gcloud iam roles undelete viewer --project $DEVSHELL_PROJECT_ID