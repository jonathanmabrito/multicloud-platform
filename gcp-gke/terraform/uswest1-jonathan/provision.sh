#Install Google CLI
apt-get -y update && \
apt-get -y install gcc python2.7 python2-dev python3-pip wget ca-certificates software-properties-common curl apt-transport-https

# Install Git >2.0.1
add-apt-repository ppa:git-core/ppa
apt-get -y update 
apt-get -y install git

# Setup Google Cloud SDK (latest)
mkdir -p /builder
#wget -qO- https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-392.0.0-linux-x86_64.tar.gz | tar zxv -C /builder
wget -qO- https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz | tar zxv -C /builder
/builder/google-cloud-sdk/install.sh --usage-reporting=false --bash-completion=true --disable-installation-options

# install crcmod: https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod
pip install -U crcmod
pip3 install -U crcmod

# Clean up
apt-get -y remove gcc python-dev wget python-pip python3-pip
rm -rf /var/lib/apt/lists/*
rm -rf ~/.config/gcloud

#Install Helm v3.7.1
echo "***********************"
echo "Installing HELM"
echo "***********************"
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm

#Add Helm Repo

#Login into GCP
echo "***********************"
echo "Logging into GCP"
echo "***********************"
/builder/google-cloud-sdk/bin/gcloud init --no-launch-browser
/builder/google-cloud-sdk/bin/gcloud config set account 729705515652@cloudbuild.gserviceaccount.com
/builder/google-cloud-sdk/bin/gcloud auth application-default login --no-launch-browser

echo "***********************"
echo "Logging into GKE"
echo "***********************"
/builder/google-cloud-sdk/bin/gcloud container clusters get-credentials cluster02 --region us-west1 --project gts-multicloud-pe-dev

#Create or use namespace
kubectl get namespaces