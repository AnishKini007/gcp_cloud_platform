#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Deploy the GCP Platform Portal application
.DESCRIPTION
    Builds and deploys the portal dashboard to GKE
#>

$ErrorActionPreference = "Stop"

Write-Host "🚀 Deploying GCP Platform Portal..." -ForegroundColor Cyan

# Get project ID
$PROJECT_ID = gcloud config get-value project
if (-not $PROJECT_ID) {
    Write-Host "❌ No GCP project configured. Run: gcloud config set project YOUR_PROJECT_ID" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Project: $PROJECT_ID" -ForegroundColor Green

# Build and push portal image
Write-Host "`n🔨 Building portal Docker image..." -ForegroundColor Cyan
Set-Location applications\portal

docker build -t asia-south1-docker.pkg.dev/$PROJECT_ID/gcp-platform/portal:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n📤 Pushing image to Artifact Registry..." -ForegroundColor Cyan
docker push asia-south1-docker.pkg.dev/$PROJECT_ID/gcp-platform/portal:latest
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker push failed" -ForegroundColor Red
    exit 1
}

Set-Location ..\..

# Update kubectl context
Write-Host "`n🔧 Configuring kubectl..." -ForegroundColor Cyan
gcloud container clusters get-credentials gcp-platform-primary `
    --region=asia-south1 `
    --project=$PROJECT_ID

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get cluster credentials" -ForegroundColor Red
    exit 1
}

# Deploy to Kubernetes
Write-Host "`n☸️  Deploying to Kubernetes..." -ForegroundColor Cyan
kubectl apply -f kubernetes\base\portal.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Kubernetes deployment failed" -ForegroundColor Red
    exit 1
}

# Wait for deployment
Write-Host "`n⏳ Waiting for portal to be ready..." -ForegroundColor Cyan
kubectl wait --for=condition=available --timeout=300s deployment/portal

# Get LoadBalancer IP
Write-Host "`n🌐 Getting portal URL..." -ForegroundColor Cyan
Write-Host "Waiting for LoadBalancer IP assignment (this may take 2-3 minutes)..." -ForegroundColor Yellow

$maxAttempts = 30
$attempt = 0
$portalIP = ""

while ($attempt -lt $maxAttempts) {
    $attempt++
    $portalIP = kubectl get service portal -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
    
    if ($portalIP) {
        break
    }
    
    Write-Host "  Attempt $attempt/$maxAttempts - waiting..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
}

if (-not $portalIP) {
    Write-Host "⚠️  LoadBalancer IP not yet assigned. Check status with:" -ForegroundColor Yellow
    Write-Host "   kubectl get service portal" -ForegroundColor White
} else {
    Write-Host "`n✅ Portal deployment complete!" -ForegroundColor Green
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "🎯 ACCESS YOUR PORTAL AT:" -ForegroundColor Green
    Write-Host "`n   http://$portalIP" -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "`nThis is your single entry point to access all GCP platform resources!" -ForegroundColor Yellow
    
    # Try to open in browser
    Write-Host "`n🌐 Opening portal in browser..." -ForegroundColor Cyan
    Start-Process "http://$portalIP"
}

Write-Host "`n📊 Portal status:" -ForegroundColor Cyan
kubectl get all -l app=portal

Write-Host "`n✨ Done!" -ForegroundColor Green
