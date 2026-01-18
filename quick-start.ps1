# Quick Start Script for Windows
# Run this script to quickly set up and deploy the GCP platform

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "GCP Platform Quick Start" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Initial setup
Write-Host "[Step 1/4] Running initial setup..." -ForegroundColor Yellow
.\scripts\setup.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Setup failed. Please check the errors above." -ForegroundColor Red
    exit 1
}

# Step 2: Deploy infrastructure
Write-Host ""
Write-Host "[Step 2/4] Deploying Terraform infrastructure..." -ForegroundColor Yellow
Write-Host "This will take approximately 15-20 minutes..." -ForegroundColor Gray
Set-Location terraform\environments\prod

terraform init
if ($LASTEXITCODE -ne 0) { exit 1 }

terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) { exit 1 }

$confirm = Read-Host "Review the plan above. Continue with deployment? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

terraform apply tfplan
if ($LASTEXITCODE -ne 0) { exit 1 }

Set-Location ..\..\..

# Step 3: Get cluster credentials
Write-Host ""
Write-Host "[Step 3/4] Configuring kubectl..." -ForegroundColor Yellow
$PROJECT_ID = gcloud config get-value project

gcloud container clusters get-credentials gcp-platform-primary `
    --region=asia-south1 `
    --project=$PROJECT_ID

# Step 4: Deploy applications
Write-Host ""
Write-Host "[Step 4/4] Deploying applications..." -ForegroundColor Yellow

# Update PROJECT_ID in manifests
Get-ChildItem -Path "kubernetes\base" -Filter "*.yaml" -Recurse | ForEach-Object {
    (Get-Content $_.FullName) -replace 'PROJECT_ID', $PROJECT_ID | Set-Content $_.FullName
}

kubectl apply -f kubernetes\base\api-service.yaml
kubectl apply -f kubernetes\base\worker-service.yaml
kubectl apply -f kubernetes\base\frontend.yaml
kubectl apply -f kubernetes\base\hpa.yaml

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Deployment Complete! 🎉" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Show service URLs
Write-Host "Waiting for external IPs to be assigned..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Green
kubectl get services

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Wait for external IPs to be assigned (may take a few minutes)" -ForegroundColor White
Write-Host "2. Test your API: kubectl get service api-service" -ForegroundColor White
Write-Host "3. View logs: kubectl logs -l app=api-service" -ForegroundColor White
Write-Host "4. View monitoring: https://console.cloud.google.com/monitoring" -ForegroundColor White
