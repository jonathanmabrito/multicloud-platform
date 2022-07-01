#Login into GCP
echo "***********************"
echo "Logging into GCP"
echo "***********************"
/builder/google-cloud-sdk/bin/gcloud init --no-launch-browser

echo "***********************"
echo "Logging into GKE"
echo "***********************"
/builder/google-cloud-sdk/bin/gcloud components install kubectl
/builder/google-cloud-sdk/bin/gcloud container clusters get-credentials cluster02 --region us-west1 --project gts-multicloud-pe-dev

#Create or use namespace
ls -la /builder/google-cloud-sdk/bin/
/builder/google-cloud-sdk/bin/kubectl get namespaces

kubectl get namespaces