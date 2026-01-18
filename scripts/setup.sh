#!/bin/bash

# GCP Infrastructure Setup Script
# This script sets up the initial GCP infrastructure

set -e

echo "======================================"
echo "GCP Platform Setup Script"
echo "======================================"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed"
    exit 1
fi

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed"
    exit 1
fi

# Prompt for project ID
read -p "Enter your GCP Project ID: " PROJECT_ID
read -p "Enter your email for notifications: " EMAIL
read -p "Enter primary region (default: asia-south1): " REGION
REGION=${REGION:-asia-south1}

echo ""
echo "Configuration:"
echo "  Project ID: $PROJECT_ID"
echo "  Email: $EMAIL"
echo "  Region: $REGION"
echo ""
read -p "Continue with this configuration? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Setup cancelled"
    exit 0
fi

# Set active project
echo "Setting active GCP project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "Enabling required GCP APIs..."
gcloud services enable \
    compute.googleapis.com \
    container.googleapis.com \
    sqladmin.googleapis.com \
    bigquery.googleapis.com \
    storage-api.googleapis.com \
    pubsub.googleapis.com \
    cloudbuild.googleapis.com \
    clouddeploy.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    cloudtrace.googleapis.com \
    secretmanager.googleapis.com \
    artifactregistry.googleapis.com

# Create Terraform state bucket
echo "Creating Terraform state bucket..."
BUCKET_NAME="${PROJECT_ID}-terraform-state"
gsutil mb -p $PROJECT_ID -l $REGION gs://$BUCKET_NAME/ || echo "Bucket already exists"
gsutil versioning set on gs://$BUCKET_NAME/

# Create Artifact Registry repository
echo "Creating Artifact Registry repository..."
gcloud artifacts repositories create gcp-platform \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for GCP Platform" || echo "Repository already exists"

# Update terraform.tfvars
echo "Creating terraform.tfvars..."
cat > terraform/environments/prod/terraform.tfvars <<EOF
project_id          = "$PROJECT_ID"
region              = "$REGION"
secondary_region    = "asia-southeast1"
environment         = "prod"
project_name        = "gcp-platform"
notification_email  = "$EMAIL"
EOF

# Update backend configuration
echo "Updating Terraform backend configuration..."
sed -i "s/REPLACE_WITH_YOUR_BUCKET_NAME/$PROJECT_ID/g" terraform/backend.tf

echo ""
echo "======================================"
echo "Setup completed successfully!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Navigate to terraform/environments/prod/"
echo "2. Run 'terraform init'"
echo "3. Run 'terraform plan' to review changes"
echo "4. Run 'terraform apply' to create infrastructure"
echo ""
echo "For CI/CD setup:"
echo "1. Update cicd/setup-triggers.sh with your GitHub username"
echo "2. Run './cicd/setup-triggers.sh'"
echo ""
