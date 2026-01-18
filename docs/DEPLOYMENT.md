# Deployment Guide

This guide walks you through deploying the GCP Cloud Infrastructure Platform from scratch.

## Prerequisites

Before you begin, ensure you have:

- ✅ GCP Account with billing enabled
- ✅ `gcloud` CLI installed ([Install Guide](https://cloud.google.com/sdk/docs/install))
- ✅ Terraform >= 1.6.0 ([Download](https://www.terraform.io/downloads))
- ✅ `kubectl` installed ([Install Guide](https://kubernetes.io/docs/tasks/tools/))
- ✅ Docker installed (for local development)
- ✅ Project Owner or Editor role in GCP

## Step 1: Initial GCP Setup

### 1.1 Create GCP Project (if new)

```bash
# Create new project
gcloud projects create YOUR_PROJECT_ID --name="GCP Platform"

# Set as active project
gcloud config set project YOUR_PROJECT_ID

# Link billing account
gcloud beta billing projects link YOUR_PROJECT_ID \
  --billing-account=YOUR_BILLING_ACCOUNT_ID
```

### 1.2 Run Setup Script

**On Linux/Mac:**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

**On Windows:**
```powershell
.\scripts\setup.ps1
```

This script will:
- Enable required GCP APIs
- Create Terraform state bucket
- Create Artifact Registry repository
- Generate `terraform.tfvars` file

## Step 2: Deploy Infrastructure with Terraform

### 2.1 Navigate to Production Environment

```bash
cd terraform/environments/prod
```

### 2.2 Review Configuration

Edit `terraform.tfvars` if needed:

```hcl
project_id          = "your-project-id"
region              = "asia-south1"
secondary_region    = "asia-southeast1"
environment         = "prod"
project_name        = "gcp-platform"
notification_email  = "your-email@example.com"
```

### 2.3 Initialize Terraform

```bash
terraform init
```

Expected output:
```
Terraform has been successfully initialized!
```

### 2.4 Plan Infrastructure

```bash
terraform plan -out=tfplan
```

Review the plan carefully. You should see resources for:
- VPC and networking
- GKE clusters (2 regions)
- Cloud SQL instances
- BigQuery datasets
- Cloud Storage buckets
- Pub/Sub topics
- IAM service accounts
- Monitoring and alerting

### 2.5 Apply Infrastructure

```bash
terraform apply tfplan
```

⏱️ **Expected time**: 15-20 minutes

This will create all infrastructure resources.

## Step 3: Configure kubectl

### 3.1 Get GKE Cluster Credentials

```bash
# Primary cluster
gcloud container clusters get-credentials gcp-platform-primary \
  --region=asia-south1 --project=YOUR_PROJECT_ID

# Verify connection
kubectl get nodes
```

### 3.2 Configure Workload Identity

```bash
# API Service
kubectl annotate serviceaccount api-service \
  iam.gke.io/gcp-service-account=gcp-platform-api-prod@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Worker Service
kubectl annotate serviceaccount worker-service \
  iam.gke.io/gcp-service-account=gcp-platform-worker-prod@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Frontend
kubectl annotate serviceaccount frontend \
  iam.gke.io/gcp-service-account=gcp-platform-frontend-prod@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

## Step 4: Build and Push Container Images

### 4.1 Configure Docker for Artifact Registry

```bash
gcloud auth configure-docker asia-south1-docker.pkg.dev
```

### 4.2 Build Images

```bash
# API Service
cd applications/api-service
docker build -t asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/gcp-platform/api-service:v1.0.0 .
docker push asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/gcp-platform/api-service:v1.0.0

# Worker Service
cd ../worker-service
docker build -t asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/gcp-platform/worker-service:v1.0.0 .
docker push asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/gcp-platform/worker-service:v1.0.0

# Frontend
cd ../frontend
docker build -t asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/gcp-platform/frontend:v1.0.0 .
docker push asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/gcp-platform/frontend:v1.0.0
```

Or use Cloud Build:

```bash
cd ../..
gcloud builds submit --config=cicd/cloudbuild/cloudbuild.yaml
```

## Step 5: Deploy Applications to GKE

### 5.1 Update Kubernetes Manifests

Update `PROJECT_ID` in all YAML files:

```bash
cd kubernetes/base
find . -type f -name "*.yaml" -exec sed -i 's/PROJECT_ID/YOUR_PROJECT_ID/g' {} +
```

### 5.2 Deploy Applications

```bash
# Deploy all services
kubectl apply -f api-service.yaml
kubectl apply -f worker-service.yaml
kubectl apply -f frontend.yaml
kubectl apply -f hpa.yaml
```

### 5.3 Verify Deployments

```bash
# Check deployments
kubectl get deployments

# Check pods
kubectl get pods

# Check services
kubectl get services
```

Wait for all pods to be in `Running` state.

## Step 6: Configure CI/CD

### 6.1 Connect GitHub Repository

```bash
# Connect Cloud Build to GitHub
gcloud builds triggers create github \
  --repo-name=gcp_cloud_platform \
  --repo-owner=YOUR_GITHUB_USERNAME \
  --branch-pattern="^main$" \
  --build-config=cicd/cloudbuild/cloudbuild.yaml
```

### 6.2 Set Up Cloud Deploy

```bash
cd cicd/deploy
sed -i 's/PROJECT_ID/YOUR_PROJECT_ID/g' clouddeploy.yaml
gcloud deploy apply --file=clouddeploy.yaml --region=asia-south1
```

## Step 7: Verify Deployment

### 7.1 Get Service URLs

```bash
# Get API service external IP
kubectl get service api-service

# Get frontend external IP
kubectl get service frontend
```

### 7.2 Test API

```bash
# Get external IP
API_IP=$(kubectl get service api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test health endpoint
curl http://$API_IP/health

# Create test event
curl -X POST http://$API_IP/events \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "test",
    "user_id": "user123",
    "data": {"message": "Hello GCP!"}
  }'

# Get events
curl http://$API_IP/events
```

### 7.3 Check Monitoring

```bash
# Open Cloud Console Monitoring
gcloud monitoring dashboards list
```

Visit: https://console.cloud.google.com/monitoring

## Step 8: Configure Monitoring & Alerts

Monitoring is already configured via Terraform. To view:

1. **Dashboards**: Cloud Console → Monitoring → Dashboards
2. **Alerts**: Cloud Console → Monitoring → Alerting
3. **SLOs**: Cloud Console → Monitoring → SLOs

## Troubleshooting

### Issue: Terraform Apply Fails

```bash
# Check API enablement
gcloud services list --enabled

# Check permissions
gcloud projects get-iam-policy YOUR_PROJECT_ID
```

### Issue: Pods Not Starting

```bash
# Check pod logs
kubectl logs <pod-name>

# Describe pod for events
kubectl describe pod <pod-name>

# Check Workload Identity binding
gcloud iam service-accounts get-iam-policy \
  gcp-platform-api-prod@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### Issue: Cannot Access Services

```bash
# Check service endpoints
kubectl get endpoints

# Check firewall rules
gcloud compute firewall-rules list

# Check load balancer
gcloud compute forwarding-rules list
```

## Cleanup

To destroy all resources:

```bash
# Delete Kubernetes resources
kubectl delete -f kubernetes/base/

# Destroy Terraform infrastructure
cd terraform/environments/prod
terraform destroy
```

## Next Steps

- ✅ Set up custom domain and SSL
- ✅ Configure Cloud Armor for DDoS protection
- ✅ Implement backup and disaster recovery testing
- ✅ Set up log aggregation and analysis
- ✅ Configure multi-region traffic routing

## Support

For issues or questions:
- Review [ARCHITECTURE.md](ARCHITECTURE.md)
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Review GCP documentation

---

**Deployment Complete! 🎉**

Your production-grade GCP infrastructure is now live and ready for Cloud Application Developer interviews!
