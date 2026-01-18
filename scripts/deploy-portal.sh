#!/usr/bin/env bash

# Deploy GCP Platform Portal
# For Linux/Mac users

set -e

echo "🚀 Deploying GCP Platform Portal..."

# Get project ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No GCP project configured. Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "📦 Project: $PROJECT_ID"

# Build and push portal image
echo -e "\n🔨 Building portal Docker image..."
cd applications/portal

docker build -t asia-south1-docker.pkg.dev/$PROJECT_ID/gcp-platform/portal:latest .
docker push asia-south1-docker.pkg.dev/$PROJECT_ID/gcp-platform/portal:latest

cd ../..

# Update kubectl context
echo -e "\n🔧 Configuring kubectl..."
gcloud container clusters get-credentials gcp-platform-primary \
    --region=asia-south1 \
    --project=$PROJECT_ID

# Deploy to Kubernetes
echo -e "\n☸️  Deploying to Kubernetes..."
kubectl apply -f kubernetes/base/portal.yaml

# Wait for deployment
echo -e "\n⏳ Waiting for portal to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/portal

# Get LoadBalancer IP
echo -e "\n🌐 Getting portal URL..."
echo "Waiting for LoadBalancer IP assignment (this may take 2-3 minutes)..."

max_attempts=30
attempt=0
portal_ip=""

while [ $attempt -lt $max_attempts ]; do
    attempt=$((attempt + 1))
    portal_ip=$(kubectl get service portal -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [ -n "$portal_ip" ]; then
        break
    fi
    
    echo "  Attempt $attempt/$max_attempts - waiting..."
    sleep 10
done

if [ -z "$portal_ip" ]; then
    echo "⚠️  LoadBalancer IP not yet assigned. Check status with:"
    echo "   kubectl get service portal"
else
    echo -e "\n✅ Portal deployment complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 ACCESS YOUR PORTAL AT:"
    echo ""
    echo "   http://$portal_ip"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This is your single entry point to access all GCP platform resources!"
    
    # Try to open in browser (works on some Linux with xdg-open, Mac with open)
    if command -v xdg-open > /dev/null; then
        xdg-open "http://$portal_ip" 2>/dev/null || true
    elif command -v open > /dev/null; then
        open "http://$portal_ip" 2>/dev/null || true
    fi
fi

echo -e "\n📊 Portal status:"
kubectl get all -l app=portal

echo -e "\n✨ Done!"
