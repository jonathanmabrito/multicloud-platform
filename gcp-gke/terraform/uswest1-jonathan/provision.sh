#Install Google CLI
apt-get -y update && \
apt-get -y install gcc python2.7 python2-dev python3-pip wget ca-certificates software-properties-common

# Install Git >2.0.1
add-apt-repository ppa:git-core/ppa
apt-get -y update 
apt-get -y install git

# Setup Google Cloud SDK (latest)
mkdir -p /builder
wget -qO- https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz | tar zxv -C /builder
/builder/google-cloud-sdk/install.sh --usage-reporting=false --bash-completion=false --disable-installation-options &

# install crcmod: https://cloud.google.com/storage/docs/gsutil/addlhelp/CRC32CandInstallingcrcmod
pip install -U crcmod
pip3 install -U crcmod

# Clean up
apt-get -y remove gcc python-dev wget python-pip python3-pip
rm -rf /var/lib/apt/lists/*
rm -rf ~/.config/gcloud

#Install Helm v.37.1

#Add Helm Repo

#Login into GCP

#Create or use namespace
