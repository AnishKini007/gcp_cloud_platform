# Build trigger configuration script

# Create Cloud Build triggers

# Trigger 1: Build and Deploy on Push to Main
gcloud builds triggers create github \
  --name="deploy-on-main" \
  --repo-name="gcp_cloud_platform" \
  --repo-owner="YOUR_GITHUB_USERNAME" \
  --branch-pattern="^main$" \
  --build-config="cicd/cloudbuild/cloudbuild.yaml" \
  --substitutions="_ENV=prod,_REGION=asia-south1,_GKE_CLUSTER=gcp-platform-primary,_ARTIFACT_REPO=gcp-platform"

# Trigger 2: Terraform Apply on Infrastructure Changes
gcloud builds triggers create github \
  --name="terraform-apply" \
  --repo-name="gcp_cloud_platform" \
  --repo-owner="YOUR_GITHUB_USERNAME" \
  --branch-pattern="^main$" \
  --build-config="cicd/cloudbuild/cloudbuild-terraform.yaml" \
  --included-files="terraform/**" \
  --substitutions="_ENV=prod"

# Trigger 3: PR Validation
gcloud builds triggers create github \
  --name="pr-validation" \
  --repo-name="gcp_cloud_platform" \
  --repo-owner="YOUR_GITHUB_USERNAME" \
  --pull-request-pattern="^.*$" \
  --build-config="cicd/cloudbuild/cloudbuild.yaml" \
  --comment-control="COMMENTS_ENABLED" \
  --substitutions="_ENV=dev,_REGION=asia-south1,_GKE_CLUSTER=gcp-platform-primary,_ARTIFACT_REPO=gcp-platform"

echo "Cloud Build triggers created successfully!"
