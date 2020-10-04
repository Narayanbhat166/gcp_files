
#Create the network in custom mode
gcloud compute networks create managementnet --subnet-mode custom;

#Create subnet
gcloud compute networks subnets create managementsubnet-us --network managementnet --region us-central1 --range 10.130.0.0/20;

#create privatenent
gcloud compute networks create privatenet --subnet-mode custom;

#create subnet in privatenet in us region
gcloud compute networks subnets create privatesubnet-us --network=privatenet --region=us-central1 --range=172.16.0.0/24;

#create subnet in privatenet in eu region
gcloud compute networks subnets create privatesubnet-eu --network=privatenet --region=europe-west1 --range=172.20.0.0/20;

#list the networks
echo "Networks created so far";
gcloud compute networks list;

#create firewall for managementnet
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp --network managementnet --source-ranges 0.0.0.0/0 --allow tcp:22,tcp:3389,icmp;

#create firewall for privatenet
gcloud compute firewall-rules create rivatenet-allow-icmp-ssh-rdp --network privatenet --source-ranges 0.0.0.0/0 --allow tcp:22,tcp:3389,icmp;

#list all firewall rules
gcloud compute firewall-rules list --sort-by=NETWORK;

#create vm
gcloud compute instances create managementnet-us-vm --machine-type f1-micro --zone us-central1-c --network managementnet --subnet managementsubnet-us;

gcloud compute instances create privatenet-us-vm --zone=us-central1-c --machine-type=n1-standard-1 --subnet=privatesubnet-us;

#list all vms
gcloud compute instances list --sort-by=ZONE;

#create vm with multiple network interfaces
gcloud compute instances create vm-appliance --zone us-central1-c --machine-type n1-standard-4 --network-interface subnet privatesubnet-us --network-interface subnet managementsubnet-us --network-interface subnet; mynetwork;
	


