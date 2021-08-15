#NOTE: make sure your terminal has gcloud cli setup with your GCP user.
#      if its not, you can run `gloud init` command.

# DO NOT run them sequentially!!!!!!!! this is just for reference

GCP_PROJECT_ID="your-project-id"


# this is a reference script to create a basic GCP cluster
gcloud beta container \
--project "$GCP_PROJECT_ID" clusters create "go-cluster" \
--zone "us-central1-c" \
--no-enable-basic-auth \
--cluster-version "1.20.8-gke.900" \
--release-channel "regular" \
--machine-type "e2-medium" \
--image-type "COS_CONTAINERD" \
--disk-type "pd-standard" --disk-size "100" \
--metadata disable-legacy-endpoints=true \
--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
--max-pods-per-node "110" \
--num-nodes "3" \
--enable-stackdriver-kubernetes \
--enable-ip-alias \
--network "projects/$GCP_PROJECT_ID/global/networks/default" \
--subnetwork "projects/$GCP_PROJECT_ID/regions/us-central1/subnetworks/default" \
--no-enable-intra-node-visibility \
--default-max-pods-per-node "110" \
--no-enable-master-authorized-networks \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
--enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 \
--max-unavailable-upgrade 0 \
--enable-shielded-nodes \
--node-locations "us-central1-c"


# to connect to cluster
gcloud container clusters get-credentials go-cluster --zone us-central1-c --project $GCP_PROJECT_ID

### To auth cluster from GitHub, you will need to use service account's json, hence we are creating this.
# create service account
gcloud iam service-accounts create github-deploy

# attach role to your service account
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member=serviceAccount:github-deploy@$GCP_PROJECT_ID.iam.gserviceaccount.com \
    --role=roles/container.developer
