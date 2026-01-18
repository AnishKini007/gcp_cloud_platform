# GCP Cloud Infrastructure Platform with Terraform & AI

A production-grade Google Cloud Platform infrastructure demonstrating enterprise-level cloud architecture, Infrastructure as Code (IaC), microservices deployment, and AI-powered infrastructure monitoring.

## 🎯 Project Overview

This project showcases a comprehensive GCP cloud infrastructure platform built from scratch, managing 15+ GCP services with Terraform IaC, containerized microservices on Kubernetes, and an AI-powered chat assistant using Vertex AI Gemini.

### 🌐 Live Services

- **Portal Dashboard**: http://35.244.59.139 - Unified dashboard with real-time service monitoring
- **API Service**: http://34.47.232.24/docs - FastAPI with interactive documentation
- **Worker Service**: http://34.47.246.239/metrics - Background processor with live metrics
- **AI Chat Assistant**: http://34.180.1.157 - Chat with AI about your infrastructure

### Key Achievements

- ✅ **AI-Powered Monitoring**: Vertex AI Gemini chatbot for infrastructure insights
- ✅ **Real-Time Dashboard**: Live health checks and service status monitoring
- ✅ **Infrastructure as Code**: Complete Terraform-managed GCP infrastructure
- ✅ **15+ GCP Services**: GKE, Cloud SQL, BigQuery, Cloud Storage, Pub/Sub, Vertex AI
- ✅ **Cloud Build CI/CD**: Automated container builds and deployments
- ✅ **Enterprise Security**: IAM with Workload Identity for zero-credential architecture
- ✅ **Multi-Region HA**: Clusters in Mumbai and Singapore regions

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                     Portal Dashboard (Next.js)                    │
│              Real-time health monitoring & navigation             │
└────────────────────────┬─────────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼─────┐    ┌────▼─────┐    ┌────▼──────┐
   │   API    │    │  Worker  │    │ Frontend  │
   │ Service  │    │ Service  │    │   Chat    │
   │ FastAPI  │    │ Pub/Sub  │    │    AI     │
   └────┬─────┘    └────┬─────┘    └────┬──────┘
        │               │               │
        └───────┬───────┴───────┬───────┘
                │               │
   ┌────────────▼───────────────▼────────────┐
   │        GKE Cluster (asia-south1)        │
   │     3 Microservices with HPA & LB       │
   └────────────┬─────────────────────────────┘
                │
   ┌────────────┼──────────────┬──────────────┐
   │            │              │              │
┌──▼───┐  ┌───▼────┐  ┌──────▼─────┐  ┌─────▼──────┐
│Cloud │  │BigQuery│  │  Pub/Sub   │  │ Vertex AI  │
│ SQL  │  │        │  │            │  │   Gemini   │
└──────┘  └────────┘  └────────────┘  └────────────┘
```

## 🛠️ Technology Stack

### Infrastructure & Cloud
- **Cloud Provider**: Google Cloud Platform (GCP)
- **IaC Tool**: Terraform 1.6+
- **Container Orchestration**: Google Kubernetes Engine (GKE)
- **Database**: Cloud SQL (PostgreSQL)
- **Data Warehouse**: BigQuery
- **Message Queue**: Cloud Pub/Sub
- **Storage**: Cloud Storage

### CI/CD & DevOps
- **CI/CD**: Cloud Build, Cloud Deploy
- **Version Control**: Git (GitHub/Cloud Source Repositories)
- **Container Registry**: Artifact Registry

### Observability & Security
- **Monitoring**: Cloud Monitoring (Stackdriver)
- **Logging**: Cloud Logging
- **Dashboards**: Grafana
- **Alerting**: Cloud Monitoring Alerts
- **Security**: Cloud IAM, Workload Identity, Secret Manager

## 📁 Project Structure

```
gcp_cloud_platform/
│
├── terraform/                      # Terraform Infrastructure Code
│   ├── environments/               # Environment-specific configs
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── modules/                    # Reusable Terraform modules
│   │   ├── gke/                   # GKE cluster module
│   │   ├── networking/            # VPC, subnets, firewall rules
│   │   ├── cloud-sql/             # Cloud SQL database
│   │   ├── bigquery/              # BigQuery datasets
│   │   ├── storage/               # Cloud Storage buckets
│   │   ├── pubsub/                # Pub/Sub topics and subscriptions
│   │   ├── iam/                   # IAM roles and service accounts
│   │   └── monitoring/            # Monitoring and alerting
│   └── backend.tf                 # Terraform state backend
│
├── applications/                   # Sample microservices
│   ├── api-service/               # REST API service
│   ├── worker-service/            # Background worker
│   └── frontend/                  # Frontend application
│
├── kubernetes/                     # K8s manifests
│   ├── base/                      # Base configurations
│   ├── overlays/                  # Kustomize overlays
│   └── helm-charts/               # Helm charts
│
├── cicd/                          # CI/CD configurations
│   ├── cloudbuild/                # Cloud Build configs
│   │   ├── cloudbuild.yaml       # Main build pipeline
│   │   ├── cloudbuild-deploy.yaml # Deployment pipeline
│   │   └── cloudbuild-terraform.yaml
│   └── deploy/                    # Cloud Deploy configs
│       └── clouddeploy.yaml
│
├── monitoring/                     # Observability configs
│   ├── grafana/                   # Grafana dashboards
│   ├── alerts/                    # Alert policies
│   └── slo/                       # SLO definitions
│
├── scripts/                        # Automation scripts
│   ├── setup.sh                   # Initial setup script
│   ├── deploy.sh                  # Deployment script
│   └── destroy.sh                 # Cleanup script
│
└── docs/                          # Documentation
    ├── ARCHITECTURE.md            # Architecture details
    ├── DEPLOYMENT.md              # Deployment guide
    └── TROUBLESHOOTING.md         # Common issues
```

## 🚀 Complete Deployment Guide

### Prerequisites

Before starting, ensure you have:

- ✅ **GCP Account** with billing enabled
- ✅ **Google Cloud SDK** installed ([Download](https://cloud.google.com/sdk/docs/install))
- ✅ **Terraform** >= 1.0 ([Download](https://www.terraform.io/downloads))
- ✅ **kubectl** CLI tool ([Install Guide](https://kubernetes.io/docs/tasks/tools/))
- ✅ **Git** for cloning the repository

### Step-by-Step Deployment

#### Step 1: Initial GCP Setup

```powershell
# Login to Google Cloud
gcloud auth login
gcloud auth application-default login

# Set your project ID (create new project in console first if needed)
$PROJECT_ID = "your-project-id"
gcloud config set project $PROJECT_ID

# Enable all required APIs (takes 2-3 minutes)
gcloud services enable compute.googleapis.com `
  container.googleapis.com `
  sqladmin.googleapis.com `
  storage.googleapis.com `
  bigquery.googleapis.com `
  pubsub.googleapis.com `
  artifactregistry.googleapis.com `
  cloudbuild.googleapis.com `
  aiplatform.googleapis.com `
  servicenetworking.googleapis.com
```

#### Step 2: Create Terraform Backend

```powershell
# Create Cloud Storage bucket for Terraform state
gsutil mb -p $PROJECT_ID -l asia-south1 gs://${PROJECT_ID}-terraform-state

# Enable versioning for state backup
gsutil versioning set on gs://${PROJECT_ID}-terraform-state
```

#### Step 3: Configure Terraform Variables

```powershell
cd terraform

# Create terraform.tfvars file
@"
project_id = "$PROJECT_ID"
region     = "asia-south1"
zone       = "asia-south1-a"

# Database settings
db_name     = "production_db"
db_user     = "admin"
db_password = "YourSecurePassword123!"  # Change this!

# Network settings
vpc_name = "gcp-vpc"
"@ | Out-File -FilePath terraform.tfvars -Encoding utf8
```

#### Step 4: Update Backend Configuration

Edit `terraform/main.tf` and update the backend:

```hcl
terraform {
  backend "gcs" {
    bucket = "your-project-id-terraform-state"  # Replace with your bucket name
    prefix = "terraform/state"
  }
}
```

#### Step 5: Deploy Infrastructure

```powershell
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy infrastructure (takes 10-15 minutes)
terraform apply -auto-approve
```

**What gets created:**
- 2 GKE clusters (asia-south1, asia-southeast1)
- Cloud SQL PostgreSQL (primary + read replica)
- BigQuery dataset
- 4 Cloud Storage buckets
- Pub/Sub topics and subscriptions
- VPC network with firewall rules
- IAM service accounts
- Artifact Registry repository

#### Step 6: Configure kubectl Access

```powershell
# Get credentials for primary GKE cluster
gcloud container clusters get-credentials primary-gke-cluster `
  --region=asia-south1 `
  --project=$PROJECT_ID

# Verify connection
kubectl get nodes
# You should see 3 nodes running
```

#### Step 7: Build and Deploy Services

**7.1 Deploy API Service**

```powershell
cd ..\applications\api-service

# Build container image with Cloud Build (takes 3-5 minutes)
gcloud builds submit --config cloudbuild.yaml `
  --substitutions=_PROJECT_ID=$PROJECT_ID,_REGION=asia-south1

# Deploy to Kubernetes
kubectl apply -f ..\..\kubernetes\base\api-service.yaml

# Wait for external IP (takes 2-3 minutes)
kubectl get service api-service -w
# Press Ctrl+C when EXTERNAL-IP appears
```

**7.2 Deploy Worker Service**

```powershell
cd ..\worker-service

# Build image
gcloud builds submit --config cloudbuild.yaml `
  --substitutions=_PROJECT_ID=$PROJECT_ID,_REGION=asia-south1

# Deploy to Kubernetes
kubectl apply -f ..\..\kubernetes\base\worker-service.yaml

# Verify pods are running
kubectl get pods -l app=worker-service
```

**7.3 Deploy Frontend Chat**

```powershell
cd ..\frontend

# Build image
gcloud builds submit --config cloudbuild.yaml `
  --substitutions=_PROJECT_ID=$PROJECT_ID,_REGION=asia-south1

# Deploy to Kubernetes
kubectl apply -f ..\..\kubernetes\base\frontend.yaml

# Wait for external IP
kubectl get service frontend -w
```

**7.4 Deploy Portal Dashboard**

```powershell
cd ..\portal

# Build image
gcloud builds submit --config cloudbuild.yaml `
  --substitutions=_PROJECT_ID=$PROJECT_ID,_REGION=asia-south1

# Deploy to Kubernetes
kubectl apply -f ..\..\kubernetes\base\portal.yaml

# Get portal IP
kubectl get service portal -w
```

#### Step 8: Configure AI Workload Identity

```powershell
# Create service account for API service
gcloud iam service-accounts create api-service-sa `
  --display-name="API Service Account" `
  --project=$PROJECT_ID

# Grant Vertex AI permissions
gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:api-service-sa@${PROJECT_ID}.iam.gserviceaccount.com" `
  --role="roles/aiplatform.user"

# Bind Kubernetes SA to GCP SA
gcloud iam service-accounts add-iam-policy-binding `
  api-service-sa@${PROJECT_ID}.iam.gserviceaccount.com `
  --role roles/iam.workloadIdentityUser `
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[default/api-service]"

# Annotate Kubernetes service account
kubectl annotate serviceaccount api-service `
  iam.gke.io/gcp-service-account=api-service-sa@${PROJECT_ID}.iam.gserviceaccount.com

# Restart API pods to pick up new identity
kubectl rollout restart deployment api-service
```

#### Step 9: Get Your Service URLs

```powershell
# Get all service IPs
echo "Portal Dashboard: http://$(kubectl get service portal -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "API Documentation: http://$(kubectl get service api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/docs"
echo "Worker Metrics: http://$(kubectl get service worker-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/metrics"
echo "AI Chat Interface: http://$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
```

#### Step 10: Update Portal Configuration (Important!)

After getting all external IPs, update the portal to show correct service links:

Edit `applications\portal\src\app\api\services\route.ts`:

```typescript
const services = [
  {
    name: 'API Service',
    url: 'http://YOUR_API_IP/docs',  // Replace with actual IP from step 9
    healthUrl: 'http://YOUR_API_IP/health',
    // ...
  },
  {
    name: 'Worker Service',
    url: 'http://YOUR_WORKER_IP/metrics',  // Replace with actual IP
    healthUrl: 'http://YOUR_WORKER_IP/health',
    // ...
  },
  {
    name: 'Frontend App',
    url: 'http://YOUR_FRONTEND_IP',  // Replace with actual IP
    healthUrl: 'http://YOUR_FRONTEND_IP',
    // ...
  }
];
```

Then rebuild and redeploy the portal:

```powershell
cd applications\portal
gcloud builds submit --config cloudbuild.yaml `
  --substitutions=_PROJECT_ID=$PROJECT_ID,_REGION=asia-south1
kubectl rollout restart deployment portal
```

#### Step 11: Verify Everything Works

```powershell
# Check all pods are running
kubectl get pods

# Check all services have external IPs
kubectl get services

# Test API health
curl http://YOUR_API_IP/health

# Test worker metrics
curl http://YOUR_WORKER_IP/metrics

# Open portal in browser
Start-Process "http://YOUR_PORTAL_IP"
```

### 🎉 You're Done!

Access your unified platform dashboard at `http://YOUR_PORTAL_IP` where you can:
- ✅ Monitor real-time health of all services
- ✅ Access API documentation
- ✅ View worker service metrics
- ✅ Chat with AI assistant about your infrastructure

## 📊 Features Overview

### 1. Portal Dashboard (Next.js 14)
- **Real-time Health Monitoring**: Auto-refreshing service status every 30 seconds
- **One-Click Access**: Direct links to all services and GCP resources
- **Service Cards**: Visual status indicators with clickable links
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Modern UI**: Clean interface with gradient backgrounds

### 2. API Service (FastAPI)
- **REST API**: Production-ready FastAPI endpoints
- **Interactive Docs**: Swagger UI at `/docs` endpoint
- **Health Checks**: `/health` endpoint for monitoring
- **Vertex AI Integration**: `/chat` endpoint powered by Gemini 2.0
- **Infrastructure Context**: AI assistant with real-time infrastructure knowledge
- **Workload Identity**: Secure authentication without service account keys

### 3. Worker Service (Python + Pub/Sub)
- **Message Processing**: Consumes messages from Cloud Pub/Sub
- **HTTP Metrics**: Real-time metrics at `/metrics` endpoint
- **Health Monitoring**: Built-in health check endpoint
- **Error Tracking**: Tracks processing errors and success rates
- **Scalable**: Deployed with HPA (Horizontal Pod Autoscaler)

### 4. AI Chat Interface (React + Vite)
- **Conversational AI**: Chat with Gemini about your infrastructure
- **Suggested Questions**: Quick-start prompts for common queries
- **Real-time Responses**: Streaming AI responses with typing animation
- **Infrastructure Awareness**: AI knows your deployment status, metrics, and health
- **Modern UI**: Clean chat interface with message bubbles

### 5. Infrastructure as Code (Terraform)
- **Multi-Region Deployment**: Clusters in Mumbai and Singapore
- **15+ GCP Services**: Complete infrastructure automation
- **Remote State**: Terraform state stored in Cloud Storage
- **Modular Design**: Reusable modules for each service
- **Version Control**: All infrastructure defined in code

### 6. Cloud Build CI/CD
- **Automated Builds**: Container images built in the cloud
- **No Docker Required**: Uses Cloud Build instead of local Docker
- **Artifact Registry**: Images stored in GCP Artifact Registry
- **Fast Builds**: Parallel builds with caching
- **Secure**: No credentials needed, uses GCP IAM

### 7. Security & IAM
- **Workload Identity**: Pods authenticate as GCP service accounts
- **Zero Keys**: No service account JSON keys stored anywhere
- **Least Privilege**: Each service has minimal required permissions
- **Network Security**: VPC with firewall rules
- **Encrypted Storage**: All data encrypted at rest

## 🎯 What Makes This Special

### AI-Powered Infrastructure Monitoring
Unlike traditional dashboards, this platform includes an AI assistant that can:
- Answer questions about your infrastructure in natural language
- Check real-time service health and metrics
- Explain what services are doing
- Help troubleshoot issues

**Example conversations:**
```
User: "What is the current health status of the infrastructure?"
AI: "The infrastructure appears healthy overall. The API Service is running 
     with 3 pods. The Worker Service has processed 2 messages with 0 errors..."

User: "How many messages has the worker processed?"
AI: "The Worker Service has processed a total of 2 messages with 0 errors. 
     The last message was processed at 2026-01-18T18:31:45..."
```

### Unified Entry Point
**Single Portal Dashboard** provides access to:
- All deployed microservices
- GCP Console resources (GKE, Cloud SQL, BigQuery)
- Service health monitoring
- Direct links to documentation
- AI chat assistant

No need to remember multiple URLs or navigate complex console menus.

### Real Production Architecture
This isn't just a demo - it's production-grade infrastructure featuring:
- Multi-region high availability
- Horizontal pod autoscaling
- Database replication
- Load balancing
- Monitoring and alerting
- Security best practices

## 💰 Cost Breakdown

**Daily Running Costs** (all regions, all services):

| Service | Cost/Day | Notes |
|---------|----------|-------|
| GKE Clusters (2x) | ~$6.00 | 2 regional clusters, 3 nodes each |
| Cloud SQL | ~$0.90 | Primary + read replica |
| Load Balancers (4x) | ~$0.60 | One per service |
| Cloud Storage | ~$0.20 | 4 buckets, minimal usage |
| Pub/Sub | ~$0.10 | Low message volume |
| BigQuery | ~$0.10 | Storage only, no queries |
| Networking | ~$0.10 | Inter-region traffic |
| **Total** | **~$8.00/day** | **~$240/month** |

**Cost Optimization:**
- Pause GKE clusters when not in use: Saves ~$6/day
- Use single region: Saves ~$3/day
- Reduce node count: Saves ~$2/day per node
- Scale down during off-hours: Saves 50-70%

**For demonstration purposes** (running 1-2 days): ~$15-20 total

## �️ Management & Operations

### Monitoring Commands

```powershell
# Check all services status
kubectl get all

# Check pod health and details
kubectl get pods -o wide

# View service endpoints and IPs
kubectl get services

# Check recent events
kubectl get events --sort-by='.lastTimestamp' --limit=20

# View application logs
kubectl logs -f deployment/api-service
kubectl logs -f deployment/worker-service
kubectl logs -f deployment/frontend

# Check resource usage
kubectl top nodes
kubectl top pods
```

### Scaling Operations

```powershell
# Scale specific deployment manually
kubectl scale deployment api-service --replicas=5

# Scale GKE cluster nodes
gcloud container clusters resize primary-gke-cluster `
  --num-nodes=5 `
  --region=asia-south1

# View HPA (Horizontal Pod Autoscaler) status
kubectl get hpa
```

### Debugging & Troubleshooting

```powershell
# Describe pod for detailed info
kubectl describe pod <pod-name>

# Get into a running container
kubectl exec -it <pod-name> -- /bin/bash

# View service details
kubectl describe service api-service

# Check deployments status
kubectl rollout status deployment/api-service

# View deployment history
kubectl rollout history deployment/api-service

# Rollback to previous version
kubectl rollout undo deployment/api-service
```

### Cost Management

```powershell
# Stop GKE clusters to save costs (use during breaks)
gcloud container clusters resize primary-gke-cluster `
  --num-nodes=0 `
  --region=asia-south1

# Resume GKE clusters
gcloud container clusters resize primary-gke-cluster `
  --num-nodes=3 `
  --region=asia-south1

# Destroy everything (WARNING: Deletes all resources)
cd terraform
terraform destroy -auto-approve
```

**Cost Estimate:**
- **Running continuously**: ~$7-8 per day (~$210-240/month)
- **Running 8 hours/day**: ~$3-4 per day (~$90-120/month)

Main cost drivers:
- GKE clusters: ~$6/day (2 regional clusters with 3 nodes each)
- Cloud SQL: ~$0.90/day (primary + replica)
- Load Balancers: ~$0.60/day (4 LoadBalancer services)
- Other services: ~$0.50/day (storage, networking, etc.)

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: Terraform State Bucket Not Found
**Error:** `Error: Failed to get existing workspaces: storage: bucket doesn't exist`

**Solution:**
```powershell
# Create the state bucket manually
gsutil mb -p $PROJECT_ID -l asia-south1 gs://${PROJECT_ID}-terraform-state
gsutil versioning set on gs://${PROJECT_ID}-terraform-state

# Re-run terraform init
terraform init
```

#### Issue 2: ImagePullBackOff on Kubernetes Pods
**Error:** `Failed to pull image... unauthorized: authentication required`

**Solution:**
```powershell
# Configure GKE to access Artifact Registry
gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:$(gcloud iam service-accounts list --format='value(email)' --filter='displayName:Compute Engine default service account')" `
  --role="roles/artifactregistry.reader"

# Delete and recreate the pod
kubectl delete pod <pod-name>
```

#### Issue 3: Service Stuck in Pending (No External IP)
**Error:** Service shows `<pending>` for EXTERNAL-IP

**Solution:**
```powershell
# Wait 2-3 minutes - LoadBalancers take time to provision
kubectl get service <service-name> -w

# If still pending after 5 minutes, check events
kubectl describe service <service-name>

# Check if you've hit quota limits
gcloud compute project-info describe --project=$PROJECT_ID
```

#### Issue 4: Vertex AI Permission Denied
**Error:** `403 Permission denied on resource project`

**Solution:**
```powershell
# Ensure Vertex AI API is enabled
gcloud services enable aiplatform.googleapis.com

# Re-apply Workload Identity binding (from Step 8)
gcloud iam service-accounts add-iam-policy-binding `
  api-service-sa@${PROJECT_ID}.iam.gserviceaccount.com `
  --role roles/iam.workloadIdentityUser `
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[default/api-service]"

# Restart API pods
kubectl rollout restart deployment api-service
```

#### Issue 5: Gemini Model Not Found
**Error:** `Model gemini-pro is not found`

**Solution:**
The correct model name is `gemini-2.0-flash-exp` and it's only available in `us-central1` region.

Check `applications/api-service/app/main.py`:
```python
VERTEX_REGION = "us-central1"  # Not asia-south1!
gemini_model = GenerativeModel("gemini-2.0-flash-exp")  # Correct model name
```

#### Issue 6: Worker Service Shows 0/1 Ready
**Error:** Pod shows `0/1` in READY column

**Solution:**
```powershell
# Check pod logs
kubectl logs <worker-pod-name>

# Common cause: Health check failing
# Ensure worker has HTTP server running on port 8080
# Check applications/worker-service/app/main.py has:
# app = Flask(__name__)
# server = make_server('0.0.0.0', 8080, app)
```

#### Issue 7: Portal Doesn't Show Service Status
**Error:** All services show as "Unknown" or health checks fail

**Solution:**
Update service URLs in `applications/portal/src/app/api/services/route.ts` with actual IPs:
```powershell
# Get all IPs
kubectl get services

# Edit portal config with real IPs
# Then rebuild and redeploy
cd applications\portal
gcloud builds submit --config cloudbuild.yaml --substitutions=_PROJECT_ID=$PROJECT_ID,_REGION=asia-south1
kubectl rollout restart deployment portal
```

#### Issue 8: Cloud Build Fails with Timeout
**Error:** `Build timeout exceeded`

**Solution:**
```powershell
# Increase timeout in cloudbuild.yaml
# Add to each build step:
timeout: '1200s'  # 20 minutes

# Or use --timeout flag
gcloud builds submit --config cloudbuild.yaml --timeout=20m
```

#### Issue 9: Out of Resources / Quota Exceeded
**Error:** `Quota 'CPUS' exceeded. Limit: 24.0 in region asia-south1`

**Solution:**
```powershell
# Request quota increase in GCP Console:
# IAM & Admin > Quotas > Filter: "Compute Engine API" > Select quota > Request increase

# Or reduce cluster size in terraform/main.tf:
# node_count = 2  # Instead of 3
```

#### Issue 10: Terraform Apply Fails with Deletion Protection
**Error:** `Error: deletion_protection is enabled`

**Solution:**
This happens when trying to destroy Cloud SQL instances. Either:

**Option A:** Disable protection first
```powershell
# Edit terraform files to set:
# deletion_protection = false

# Then apply
terraform apply
terraform destroy
```

**Option B:** Manual deletion
```powershell
# Delete manually through console or:
gcloud sql instances delete <instance-name> --quiet
```

### Getting Help

If you encounter issues not listed here:

1. **Check Kubernetes Events**: `kubectl get events --sort-by='.lastTimestamp'`
2. **View Pod Logs**: `kubectl logs <pod-name>`
3. **Describe Resources**: `kubectl describe pod/service/deployment <name>`
4. **Check GCP Console**: Often shows clearer error messages
5. **Enable Verbose Logging**: Add `-v=8` to kubectl commands for debug output

## 📚 Additional Resources

### GCP Documentation
- [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/docs)
- [Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)
- [Vertex AI](https://cloud.google.com/vertex-ai/docs)
- [Cloud Build](https://cloud.google.com/build/docs)
- [Terraform on GCP](https://cloud.google.com/docs/terraform)

### Learn More
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Next.js Documentation](https://nextjs.org/docs)

### Related Projects
This project demonstrates skills applicable to:
- Cloud Application Development
- DevOps Engineering
- Site Reliability Engineering (SRE)
- Platform Engineering
- Cloud Architecture

## 🤝 Contributing

This is a personal demonstration project. Feel free to:
- Fork for your own learning
- Adapt for your use cases
- Share feedback or suggestions

## 📄 License

MIT License - Free to use for educational and personal projects.

## 👤 About

**Project by Anish Kini**

This project demonstrates:
- ✅ End-to-end cloud infrastructure design and deployment
- ✅ Infrastructure as Code (IaC) with Terraform
- ✅ Containerized microservices architecture
- ✅ CI/CD automation with Cloud Build
- ✅ AI integration with Vertex AI
- ✅ Production-grade security and monitoring
- ✅ Cost-aware cloud resource management

**Skills Showcased:**
- Google Cloud Platform (GCP)
- Terraform Infrastructure Automation
- Kubernetes (GKE) Orchestration
- Python (FastAPI, Flask)
- JavaScript/TypeScript (Next.js, React)
- Docker & Containerization
- DevOps & CI/CD
- Cloud Cost Optimization
- AI/ML Integration (Vertex AI)

---

**Questions or Issues?** Check the [Troubleshooting Guide](#-troubleshooting-guide) above or open an issue in the repository.

**Want to see it in action?** The live demo is available at the service URLs listed at the top of this README.
