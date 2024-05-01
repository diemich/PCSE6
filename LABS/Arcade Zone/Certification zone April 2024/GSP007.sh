#!/bin/bash

#Set Up Network and HTTP Load Balancers

#variables 
export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export REGION=europe-west1
export ZONE=europe-west1-c
INSTANCE_NAMES=("www1" "www2" "www3")

#Task 1. Set the default region and zone for all resources

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

#Task 2. Create multiple web server instances

#Create a virtual machine www1 in your default zone using the following code:
  gcloud compute instances create www1 \
    --zone=$ZONE \
    --tags=network-lb-tag \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "
<h3>Web Server: www1</h3>" | tee /var/www/html/index.html'

#Create a virtual machine www2 in your default zone using the following code:
  gcloud compute instances create www2 \
    --zone=$ZONE \
    --tags=network-lb-tag \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "
<h3>Web Server: www2</h3>" | tee /var/www/html/index.html'

#Create a virtual machine www3 in your default zone.
  gcloud compute instances create www3 \
    --zone=$ZONE \
    --tags=network-lb-tag \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "
<h3>Web Server: www3</h3>" | tee /var/www/html/index.html'

#Create a firewall rule to allow external traffic to the VM instances:
gcloud compute firewall-rules create www-firewall-network-lb \
    --target-tags network-lb-tag --allow tcp:80


#Run the following to list your instances. You'll see their IP addresses in the EXTERNAL_IP column:
gcloud compute instances list

#Explore the network interface connectivity -EXTERNAL IP
get_external_ip() {
    local instance_name="$1"
    gcloud compute instances list --filter=name:$instance_name --format='value(EXTERNAL_IP)'
}

for instance in "${INSTANCE_NAMES[@]}"; do
    EXTERNAL_IP=$(get_external_ip "$instance")
    if [ -n "$EXTERNAL_IP" ]; then
        echo "External IP address of $instance: $EXTERNAL_IP"
        curl http://$EXTERNAL_IP
    else
        echo "Error: Unable to retrieve IP address for $instance"
    fi
done


#Task 3. Configure the load balancing service

#Create a static external IP address for your load balancer:
gcloud compute addresses create network-lb-ip-1 \
  --region $REGION

#Add a legacy HTTP health check resource
gcloud compute http-health-checks create basic-check

#Add a target pool in the same region as your instances. Run the following to create the target pool and use the health check, which is required for the service to function:
gcloud compute target-pools create www-pool \
  --region $REGION --http-health-check basic-check

#Add the instances to the pool:
gcloud compute target-pools add-instances www-pool \
    --instances www1,www2,www3

#Add a forwarding rule:
gcloud compute forwarding-rules create www-rule \
    --region $REGION \
    --ports 80 \
    --address network-lb-ip-1 \
    --target-pool www-pool

#Task 4. Sending traffic to your instances

#Enter the following command to view the external IP address of the www-rule forwarding rule used by the load balancer:
gcloud compute forwarding-rules describe www-rule --region $REGION

#Access the external IP address
IPADDRESS=$(gcloud compute forwarding-rules describe www-rule --region $REGION --format="json" | jq -r .IPAddress)

#Show the external IP address
echo $IPADDRESS

#Use curl command to access the external IP address, replacing IP_ADDRESS with an external IP address from the previous command:
#repeat 9 { while true; do curl -m1 $IPADDRESS; done }

#Task 5. Create an HTTP load balancer

#First, create the load balancer template:
gcloud compute instance-templates create lb-backend-template \
   --region=$REGION \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=e2-medium \
   --image-family=debian-11 \
   --image-project=debian-cloud \
   --metadata=startup-script='#!/bin/bash
     apt-get update
     apt-get install apache2 -y
     a2ensite default-ssl
     a2enmod ssl
     vm_hostname="$(curl -H "Metadata-Flavor:Google" \
     http://169.254.169.254/computeMetadata/v1/instance/name)"
     echo "Page served from: $vm_hostname" | \
     tee /var/www/html/index.html
     systemctl restart apache2'

#Create a managed instance group based on the template:

gcloud compute instance-groups managed create lb-backend-group \
    --template=lb-backend-template --size=2 --zone=$ZONE

#Create the fw-allow-health-check firewall rule.

gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80


#Now that the instances are up and running, set up a global static external IP address that your customers use to reach your load balancer:

gcloud compute addresses create lb-ipv4-1 \
  --ip-version=IPV4 \
  --global

#Note the IPv4 address that was reserved:
gcloud compute addresses describe lb-ipv4-1 \
  --format="get(address)" \
  --global

#Create a health check for the load balancer:
gcloud compute health-checks create http http-basic-check \
  --port 80

#Create a backend service:
gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global

#Add your instance group as the backend to the backend service:
gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone=$ZONE \
  --global

#Create a URL map to route the incoming requests to the default backend service:
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

#Create a target HTTP proxy to route requests to your URL map:
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http

#Create a global forwarding rule to route incoming requests to the proxy:
gcloud compute forwarding-rules create http-content-rule \
   --address=lb-ipv4-1\
   --global \
   --target-http-proxy=http-lb-proxy \
   --ports=80

#Task 6. Testing traffic sent to your instances
