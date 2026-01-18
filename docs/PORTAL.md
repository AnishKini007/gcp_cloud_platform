# 🌐 GCP Platform Portal - Quick Start

## What is the Portal?

The **GCP Platform Portal** is a unified dashboard that provides a single web interface to access all your GCP infrastructure resources. Instead of navigating to multiple URLs and consoles, you get one beautiful landing page with everything you need.

## Features

✨ **Single Entry Point** - One URL to access all platform resources  
📊 **Service Health** - Real-time status of all microservices  
🔗 **Quick Links** - Direct access to GCP Console, monitoring, databases, storage  
🎨 **Beautiful UI** - Modern, responsive design with dark mode  
⚡ **Fast** - Built with Next.js 14 for optimal performance

## Deployment

### Option 1: Quick Deploy (Recommended)

```powershell
.\scripts\deploy-portal.ps1
```

This script will:
1. Build the portal Docker image
2. Push to Artifact Registry
3. Deploy to GKE
4. Wait for LoadBalancer IP
5. Open portal in your browser automatically

### Option 2: Manual Deployment

```powershell
# 1. Build and push image
cd applications\portal
docker build -t asia-south1-docker.pkg.dev/YOUR_PROJECT/gcp-platform/portal:latest .
docker push asia-south1-docker.pkg.dev/YOUR_PROJECT/gcp-platform/portal:latest

# 2. Deploy to Kubernetes
cd ..\..
kubectl apply -f kubernetes\base\portal.yaml

# 3. Get portal URL
kubectl get service portal
```

### Option 3: Deploy Everything

Use the comprehensive build pipeline to deploy all services including portal:

```powershell
gcloud builds submit --config=cicd\cloudbuild\cloudbuild-all.yaml
```

## Accessing the Portal

### Get the URL

```powershell
# Get LoadBalancer IP
$PORTAL_IP = kubectl get service portal -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Print URL
Write-Host "Portal URL: http://$PORTAL_IP"

# Open in browser
Start-Process "http://$PORTAL_IP"
```

### Wait Time

⏱️ The LoadBalancer IP assignment takes approximately **2-3 minutes** after deployment.

## What You'll See

Once you access the portal, you'll find organized sections:

### 📦 Console & Management
- GCP Project Dashboard
- GKE Clusters Management
- Cloud SQL Databases

### 📊 Monitoring & Observability
- Cloud Monitoring Dashboards
- Cloud Logging & Traces

### 💾 Data & Storage
- BigQuery Data Warehouse
- Cloud Storage Buckets

### 🚀 CI/CD & Deployment
- Cloud Build Pipelines
- Deployment History

### 🔧 Service Status
- API Service health
- Worker Service health
- Frontend Application health

## Configuration

The portal automatically detects your project configuration from environment variables:

- `PROJECT_ID`: Your GCP project ID
- `REGION`: Primary deployment region (asia-south1)

These are set in the Kubernetes deployment manifest.

## Troubleshooting

### LoadBalancer IP not assigned

```powershell
# Check service status
kubectl get service portal

# Check events
kubectl describe service portal

# Check pod logs
kubectl logs -l app=portal
```

### Portal not accessible

```powershell
# Check if pods are running
kubectl get pods -l app=portal

# Check pod logs
kubectl logs -l app=portal --tail=50

# Check service endpoints
kubectl get endpoints portal
```

### Health check failing

```powershell
# Test health endpoint directly from pod
kubectl exec -it deployment/portal -- curl http://localhost:8080/api/health
```

## Architecture

```
┌─────────────────────────────────────────┐
│         LoadBalancer Service            │
│         (External IP: 80 → 8080)        │
└──────────────┬──────────────────────────┘
               │
    ┌──────────┴──────────┐
    │                     │
┌───▼────┐          ┌────▼───┐
│Portal  │          │Portal  │
│Pod 1   │          │Pod 2   │
└────────┘          └────────┘
    │                    │
    └────────┬───────────┘
             │
      ┌──────▼──────┐
      │   Next.js   │
      │  App Server │
      │  (Port 8080)│
      └─────────────┘
```

## Performance

- **Response Time**: < 50ms (static content)
- **Scaling**: Auto-scales 2-10 pods based on CPU/memory
- **Availability**: Multi-pod deployment with health checks
- **Resources**: 100m CPU / 128Mi RAM per pod

## Security

- ✅ Workload Identity enabled
- ✅ Minimal IAM permissions
- ✅ Health checks configured
- ✅ Resource limits enforced
- ✅ Container image scanning

## Making It Production-Ready

### Custom Domain (Optional)

1. **Reserve static IP**:
```powershell
gcloud compute addresses create portal-ip --region=asia-south1
```

2. **Update service** to use static IP:
```yaml
spec:
  type: LoadBalancer
  loadBalancerIP: "STATIC_IP_HERE"
```

3. **Configure DNS** to point to the IP

### HTTPS with Cloud Load Balancer

1. Create Google-managed SSL certificate
2. Set up Ingress resource instead of LoadBalancer service
3. Configure Cloud Armor for DDoS protection

### Custom Branding

Edit [page.tsx](../applications/portal/src/app/page.tsx):
- Change colors in `tailwind.config.ts`
- Update title in `layout.tsx`
- Add company logo
- Customize service links

## Support

For issues or questions:
1. Check pod logs: `kubectl logs -l app=portal`
2. Verify service: `kubectl describe service portal`
3. Check deployment: `kubectl describe deployment portal`

---

**🎯 The portal makes your GCP platform professional and demo-ready!**
