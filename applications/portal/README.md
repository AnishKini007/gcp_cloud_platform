# GCP Platform Portal

Unified dashboard and landing page for the GCP Cloud Infrastructure Platform.

## Features

- 🎯 **Single Entry Point**: One URL to access all platform resources
- 📊 **Service Status**: Real-time health monitoring of all microservices
- 🔗 **Quick Links**: Direct access to GCP Console, monitoring, data services
- 🎨 **Modern UI**: Clean, responsive design with dark mode support
- ⚡ **Fast**: Built with Next.js 14 and optimized for performance

## Architecture

- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Icons**: React Icons
- **Runtime**: Node.js 18
- **Deployment**: Google Kubernetes Engine (GKE)

## Local Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

Visit http://localhost:8080

## Docker

```bash
# Build image
docker build -t portal:latest .

# Run container
docker run -p 8080:8080 portal:latest
```

## Environment Variables

- `PROJECT_ID`: GCP project ID (default: gcloud-platform-484321)
- `REGION`: GCP region (default: asia-south1)
- `API_SERVICE_URL`: API service URL for health checks

## Deployment

Deployed automatically via Cloud Build when changes are pushed to the repository.

## Access

Once deployed, the portal is accessible via the LoadBalancer external IP:

```bash
kubectl get service portal -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Visit: `http://<EXTERNAL-IP>`
