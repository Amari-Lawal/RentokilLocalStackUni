# Set as current account
gcloud config set account amari.lawal@gmail.com

# Set as current project
gcloud config set project caesaraiapis

# Create a service account
gcloud iam service-accounts create amari-lawal-github-actions \
  --description="Service account for GitHub Actions" \
  --display-name="amari-lawal-github-actions"
PROJECT_ID=caesaraiapis
SA=amari-lawal-github-actions

# Grant the service account permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# List the service account keys
gcloud iam service-accounts keys list \
  --iam-account=$SA@$PROJECT_ID.iam.gserviceaccount.com

# Create a service account key
gcloud iam service-accounts keys create key.json \
  --iam-account=$SA@$PROJECT_ID.iam.gserviceaccount.com

# Create an artifact registry for the backend
gcloud artifacts repositories create rentokil-uni-registry \
    --repository-format=docker \
    --location=europe-west1 \
    --description="Docker repository for Rentokil Backend"