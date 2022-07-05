echo "***********************"
echo "Logging into GCP"
echo "***********************"
gcloud init --no-launch-browser

echo "***********************"
echo "Logging into GKE"
echo "***********************"
gcloud container clusters get-credentials cluster02 --region us-west1 --project gts-multicloud-pe-dev

echo "***********************"
echo "Add Helm Repo"
echo "***********************"
#helm repo add --force-update helm_repo ${{ env.HELM_REGISTRY }}${{ github.event.inputs.helmrepo }} --username ${{ env.HELM_REGISTRY_USER }} --password ${{ env.HELM_REGISTRY_TOKEN }}

echo "***********************"
echo "Create or use namespace"
echo "***********************"
NS=infra
if ! kubectl get namespaces $NS; then
    echo "Namespace $NS does not exist. Creating it.."
    kubectl create namespace $NS
else
    echo "Namespace $NS already exists. Will use it."
fi
kubectl config set-context --current --namespace=infra

echo "***********************"
echo "Run Helm Charts"
echo "***********************"
export NS=infra
export SERVICE=infra
export DOMAIN=domain.example.com.
#export IMAGE_REGISTRY=${{ env.IMAGE_REGISTRY }}

cd "./gcp-gke/terraform/uswest1-jonathan/cloudbuild-services/$SERVICE"
FULLCOMMAND="uninstall"
COMMAND=$(echo $FULLCOMMAND | cut -d' ' -f1)
if [[ "$FULLCOMMAND" == *" "* ]]; then
    CHART_NAME=$(echo $FULLCOMMAND | tr -s ' ' | cut -d' ' -f2)
    RL_NAME=$(echo $FULLCOMMAND | tr -s ' ' | cut -d' ' -f3)
fi

# FOR EVERY HELM CHART ############################################################
# ℹ️ Notice: in application folder should be exist subfolder with name in format: 
#      [0-9][0-9]_chart_chart-name 
# where chart-name is name of chart using to installing 
# and digits define the instalation order 
# The chart-name using in command:
#     helm install RELEASE-NAME helm-repo/chart-name
# ##################################################################################
for DIR in [0-9][0-9]_chart_*$CHART_NAME*/; do
    
    CHART=$([[ -d "$DIR" ]] && echo $DIR | sed 's/[0-9][0-9]_chart_//' | sed 's/\///')
    
    DIR=$(echo $DIR | sed 's/\///')
    
    # evaluate ENV variables
    envsubst < $DIR/override_values.yaml > overrides.yaml
    # 🖊️ (Optional) EDIT 1st line of chart.ver file with chart version number
    VER=$(head -n 1 $DIR/chart.ver)
    
    FLAGS="helm_repo/$CHART --install --version=$VER -n $NS -f $(pwd)/overrides.yaml"
    
    case $COMMAND in
    install)
        echo "Installing..."
        CMD="upgrade"
        ;;
    uninstall)
        echo "Uninstalling..."
        CMD="uninstall"
        FLAGS=""
        ;;
    validate)
        echo "Validating..."
        CMD="upgrade"
        FLAGS+=" --dry-run"
        ;;
    *)
        echo "❌ Wrong command"
        exit 1
        ;;
    esac
    cd $DIR
    
    touch overrides.yaml
    [[ "$FLAGS" ]] && FLAGS+=" -f $(pwd)/overrides.yaml"
    
    # FOR EVERY HELM RELEASE###########################################################
    # ℹ️ Notice: in chart folder should be exist subfolder with name in format: 
    #      [0-9][0-9]_release_release-name 
    # where release-name is name of release using to installing 
    # and digits define the instalation order 
    # The release-name using in command:
    #     helm install release-name helm-repo/chart-name
    #
    # If you want to run some preparing script (for ex: init database, check conditions) 
    # before installing, place you code in pre-relese-script.sh in release subfolder
    #
    # If you want to run some post-installing script (for ex: validate something),
    # place you code in post-relese-script.sh in release subfolder
    # ##################################################################################
    for DIR_RL in [0-9][0-9]_release_*$RL_NAME*/; do
        RELEASE=$([[ -d "$DIR_RL" ]] && echo $DIR_RL | sed 's/[0-9][0-9]_release_//' | sed 's/\///')
        cd $DIR_RL
        # Run pre-release-script if exists
        [[ "$COMMAND" == "install" ]] && [[ -f "pre-release-script.sh" ]] \
            && source pre-release-script.sh
        cd ..
        # evaluate ENV variables
        envsubst < $DIR_RL/override_values.yaml > overrides.yaml
        echo "helm $CMD $RELEASE $FLAGS"
        [[ "$CMD" ]] && [[ "$CHART" ]] && [[ "$RELEASE" ]] && \
                    helm $CMD $RELEASE $FLAGS
        cd $DIR_RL
        # Run post-release-script if exists
        [[ "$COMMAND" == "install" ]] && [[ -f "post-release-script.sh" ]] \
            && source post-release-script.sh
        cd ..
    
    done
    cd ..
done