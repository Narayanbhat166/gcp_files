#lab link https://www.qwiklabs.com/focuses/10258?parent=catalog
#first authenticate and then run this script if running from local gcloud sdk
#authenticate using gcloud auth login and set project id

#set default region and zone
gcloud config set compute/zone us-east1-b;
gcloud config set compute/region us-east1;

#creating instance
gcloud compute instances create nucleus-jumphost --machine-type f1-micro;

#kubernetes
#create clusters
gcloud container clusters create nucleus-cluster --zone us-east1-b;
gcloud container clusters get-credentials nucleus-cluster;

#deploy the images
kubectl create deployment nucleus-deployment --image=gcr.io/google-samples/hello-app:2.0;

#expose deployment
kubectl expose deployment nucleus-deployment --port 8080 --type LoadBalancer;

#HTTP load balancer
#store the startup script in startup.sh
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

#create instance template
gcloud compute instance-templates create nucleus-template --metadata-from-file startup-script=startup.sh --machine-type f1-micro;

#create firewall
gcloud compute firewall-rules create www-firewall --allow tcp:80;

#create target pools
gcloud compute target-pools create nginx-pool;

#create managed instance group
gcloud compute instance-groups managed create nginx-group --base-instance-name nginx --size 2 --template nucleus-template --target-pool nginx-pool; 

#create network load-balancer
#gcloud compute forwarding-rules create nginx-lb --region us-east1 --ports=80 --target-pool nginx-pool;

#create health check
gcloud compute http-health-checks create http-basic-check;

#set named port to identify the service running
gcloud compute instance-groups managed set-named-ports nginx-group --named-ports http:80;

#create a backend service
gcloud compute backend-services create nginx-backend --protocol HTTP --http-health-checks http-basic-check --global;

#add mig to backend service
gcloud compute backend-services add-backend nginx-backend --instance-group nginx-group --global --instance-group-zone $(gcloud config get-value compute/zone);

#create url map
gcloud compute url-maps create  web-map --default-service nginx-backend;

#create target proxies
gcloud compute target-http-proxies create http-lb-proxy --url-map web-map;

#create a forwarding rule
gcloud compute forwarding-rules create http-content-rule --global --target-http-proxy http-lb-proxy --ports 80;

#get the ip
gcloud compute forwarding-rules list;

echo "Wait for 10 minutes for the load balancer to come into effect";

