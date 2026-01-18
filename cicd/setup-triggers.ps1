# Build trigger configuration script for Windows PowerShell

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Creating Cloud Build Triggers" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Prompt for GitHub username
$GITHUB_USERNAME = Read-Host "Enter your GitHub username"
$PROJECT_ID = gcloud config get-value project

Write-Host ""
Write-Host "Creating triggers for project: $PROJECT_ID" -ForegroundColor Yellow
Write-Host "GitHub repository owner: $GITHUB_USERNAME" -ForegroundColor Yellow
Write-Host ""

# Trigger 1: Build and Deploy on Push to Main
Write-Host "Creating 'deploy-on-main' trigger..." -ForegroundColor Green
gcloud builds triggers create github `
  --name="deploy-on-main" `
  --repo-name="gcp_cloud_platform" `
  --repo-owner="$GITHUB_USERNAME" `
  --branch-pattern="^main$" `
  --build-config="cicd/cloudbuild/cloudbuild.yaml" `
  --substitutions="_ENV=prod,_REGION=asia-south1,_GKE_CLUSTER=gcp-platform-primary,_ARTIFACT_REPO=gcp-platform"

# Trigger 2: Terraform Apply on Infrastructure Changes
Write-Host "Creating 'terraform-apply' trigger..." -ForegroundColor Green
gcloud builds triggers create github `
  --name="terraform-apply" `
  --repo-name="gcp_cloud_platform" `
  --repo-owner="$GITHUB_USERNAME" `
  --branch-pattern="^main$" `
  --build-config="cicd/cloudbuild/cloudbuild-terraform.yaml" `
  --included-files="terraform/**" `
  --substitutions="_ENV=prod"

# Trigger 3: PR Validation
Write-Host "Creating 'pr-validation' trigger..." -ForegroundColor Green
gcloud builds triggers create github `
  --name="pr-validation" `
  --repo-name="gcp_cloud_platform" `
  --repo-owner="$GITHUB_USERNAME" `
  --pull-request-pattern="^.*$" `
  --build-config="cicd/cloudbuild/cloudbuild.yaml" `
  --comment-control="COMMENTS_ENABLED" `
  --substitutions="_ENV=dev,_REGION=asia-south1,_GKE_CLUSTER=gcp-platform-primary,_ARTIFACT_REPO=gcp-platform"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Cloud Build triggers created successfully!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "View your triggers at:" -ForegroundColor Yellow
Write-Host "https://console.cloud.google.com/cloud-build/triggers?project=$PROJECT_ID" -ForegroundColor White
