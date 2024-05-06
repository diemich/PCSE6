gcloud compute instances create linux-iap \
--zone=us-east1-d \
--machine-type=e2-medium \
--network-interface=stack-type=IPV4_ONLY,subnet=default,no-address \
--metadata=enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=847059496826-compute@developer.gserviceaccount.com \
--create-disk=auto-delete=yes,boot=yes,device-name=linux-iap,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240415,mode=rw,size=10,type=projects/qwiklabs-gcp-01-83ae6c9e5510/zones/us-east1-d/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=goog-ec-src=vm_add-gcloud \
--reservation-affinity=any

gcloud compute instances create windows-iap \
--zone=us-east1-d \
--machine-type=e2-medium \
--network-interface=stack-type=IPV4_ONLY,subnet=default,no-address \
--metadata=enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=847059496826-compute@developer.gserviceaccount.com \
--create-disk=auto-delete=yes,boot=yes,device-name=windows-iap,image=projects/windows-cloud/global/images/windows-server-2016-dc-v20240415,mode=rw,size=50,type=projects/qwiklabs-gcp-01-83ae6c9e5510/zones/us-east1-d/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=goog-ec-src=vm_add-gcloud \
--reservation-affinity=any

gcloud compute instances create windows-connectivity \
--zone=us-east1-d \
--machine-type=e2-medium \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--metadata=enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=847059496826-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/cloud-platform \
--create-disk=auto-delete=yes,boot=yes,device-name=windows-connectivity,image=projects/qwiklabs-resources/global/images/iap-desktop-v001,mode=rw,size=50,type=projects/qwiklabs-gcp-01-83ae6c9e5510/zones/us-east1-d/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=goog-ec-src=vm_add-gcloud \
--reservation-affinity=any

