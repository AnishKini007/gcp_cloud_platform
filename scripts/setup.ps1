# GCP Platform Setup Script for Windows
# PowerShell version

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "GCP Platform Setup Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if gcloud is installed
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "Error: gcloud CLI is not installed" -ForegroundColor Red
    exit 1
}

# Check if terraform is installed
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Terraform is not installed" -ForegroundColor Red
    exit 1
}

# Prompt for configuration
$PROJECT_ID = Read-Host "Enter your GCP Project ID"
$EMAIL = Read-Host "Enter your email for notifications"
$REGION = Read-Host "Enter primary region (default: asia-south1)"
if ([string]::IsNullOrEmpty($REGION)) {
    $REGION = "asia-south1"
}

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Project ID: $PROJECT_ID"
Write-Host "  Email: $EMAIL"
Write-Host "  Region: $REGION"
Write-Host ""

$CONFIRM = Read-Host "Continue with this configuration? (y/n)"
if ($CONFIRM -ne "y") {
    Write-Host "Setup cancelled" -ForegroundColor Yellow
    exit 0
}

# Set active project
Write-Host "Setting active GCP project..." -ForegroundColor Green
gcloud config set project $PROJECT_ID

# Enable required APIs
Write-Host "Enabling required GCP APIs..." -ForegroundColor Green
$apis = @(
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "bigquery.googleapis.com",
    "storage-api.googleapis.com",
    "pubsub.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouddeploy.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com"
)

foreach ($api in $apis) {
    gcloud services enable $api
}

# Create Terraform state bucket
Write-Host "Creating Terraform state bucket..." -ForegroundColor Green
$BUCKET_NAME = "$PROJECT_ID-terraform-state"
gsutil mb -p $PROJECT_ID -l $REGION gs://$BUCKET_NAME/
gsutil versioning set on gs://$BUCKET_NAME/

# Create Artifact Registry repository
Write-Host "Creating Artifact Registry repository..." -ForegroundColor Green
gcloud artifacts repositories create gcp-platform `
    --repository-format=docker `
    --location=$REGION `
    --description="Docker repository for GCP Platform"

# Create terraform.tfvars
Write-Host "Creating terraform.tfvars..." -ForegroundColor Green
$tfvarsContent = @"
project_id          = "$PROJECT_ID"
region              = "$REGION"
secondary_region    = "asia-southeast1"
environment         = "prod"
project_name        = "gcp-platform"
notification_email  = "$EMAIL"
"@

$tfvarsContent | Out-File -FilePath "terraform\environments\prod\terraform.tfvars" -Encoding UTF8

# Update backend configuration
Write-Host "Updating Terraform backend configuration..." -ForegroundColor Green
$backendPath = "terraform\backend.tf"
$backendContent = Get-Content $backendPath -Raw
$backendContent = $backendContent -replace "REPLACE_WITH_YOUR_BUCKET_NAME", $PROJECT_ID
$backendContent | Out-File -FilePath $backendPath -Encoding UTF8

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Navigate to terraform\environments\prod\" -ForegroundColor White
Write-Host "2. Run 'terraform init'" -ForegroundColor White
Write-Host "3. Run 'terraform plan' to review changes" -ForegroundColor White
Write-Host "4. Run 'terraform apply' to create infrastructure" -ForegroundColor White
Write-Host ""
