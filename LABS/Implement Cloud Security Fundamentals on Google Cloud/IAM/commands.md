# Cloud IAM: Qwik Start
## GSP064

``` [TASK LIST]
- [ ] Sign in to Cloud SDK as the first user
- [ ] The IAM console and project level roles
- [ ] Prepare a resource for access testing


```

### List members of roles for the project
```
gcloud projects get-iam-policy my-project --format=yaml > ~/policy.yaml
```
### List service accounts
```
gcloud iam service-accounts list
```

```
gcloud projects get-iam-policy $PROJECT_ID --flatten='bindings[].members' --filter="bindings.members:user:${user}" --format='value(bindings.role)' 
```
### Prepare a resource for access testing
```
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export BUCKET_NAME=${PROJECT_ID:0:9}$(date +%F)
```
### Create a bucket

```
gcloud storage buckets create gs://$BUCKET_NAME
gcloud storage ls --recursive gs://$BUCKET_NAME
```
### Upload a sample file
```
touch sample.txt && lscpu >> sample.txt 
```



https://cloud.google.com/storage/docs/access-control/iam-roles

From https://cloud.google.com/iam/docs/granting-changing-revoking-access#gcloud