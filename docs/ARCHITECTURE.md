# GCP Cloud Infrastructure Platform - Architecture

## System Architecture Overview

This document provides a detailed overview of the GCP cloud infrastructure platform architecture, designed for production-grade deployment with high availability, security, and observability.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cloud Load Balancer                       │
│                     (Global HTTP(S) Load Balancer)              │
└────────────────────────┬────────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
    ┌────▼─────────┐              ┌─────▼────────┐
    │   Region 1   │              │   Region 2   │
    │ (us-central1)│              │(europe-west1)│
    └────┬─────────┘              └─────┬────────┘
         │                               │
    ┌────▼──────────────┐          ┌────▼──────────────┐
    │  GKE Cluster      │          │  GKE Cluster      │
    │  (Primary)        │◄────────►│  (Secondary)      │
    │  - API Service    │          │  - API Service    │
    │  - Worker Service │          │  - Worker Service │
    │  - Frontend       │          │  - Frontend       │
    └────┬──────────────┘          └────┬──────────────┘
         │                               │
    ┌────▼─────────┐              ┌─────▼────────┐
    │  Cloud SQL   │              │  Cloud SQL   │
    │  (Primary)   │◄────────────►│  (Replica)   │
    │  PostgreSQL  │              │  PostgreSQL  │
    └──────────────┘              └──────────────┘
```

## Network Architecture

### VPC Configuration
- **Custom VPC**: Isolated network with complete control
- **Primary Subnet** (asia-south1 - Mumbai): 10.0.0.0/20
  - Pods: 10.4.0.0/14
  - Services: 10.8.0.0/20
- **Secondary Subnet** (asia-southeast1 - Singapore): 10.1.0.0/20
  - Pods: 10.12.0.0/14
  - Services: 10.16.0.0/20

### Security Features
- **Private GKE Clusters**: Nodes have no public IPs
- **Cloud NAT**: Controlled egress traffic
- **Firewall Rules**: Least-privilege access
- **VPC Service Controls**: Perimeter security

## Compute Layer

### GKE Clusters
- **Configuration**: Regional clusters for HA
- **Node Pools**: Auto-scaling (1-5 nodes per zone)
- **Machine Type**: e2-standard-4
- **Features**:
  - Workload Identity enabled
  - Binary Authorization enabled
  - Shielded nodes enabled
  - Network policy enabled

### Application Services

#### API Service
- **Technology**: FastAPI (Python)
- **Replicas**: 3 (auto-scaling up to 10)
- **Resources**: 
  - Requests: 250m CPU, 256Mi memory
  - Limits: 500m CPU, 512Mi memory
- **Endpoints**:
  - `/health`: Health check
  - `/events`: Event management
  - `/metrics`: Prometheus metrics

#### Worker Service
- **Technology**: Python (Pub/Sub consumer)
- **Replicas**: 2 (auto-scaling up to 8)
- **Function**: Background processing
- **Resources**:
  - Requests: 250m CPU, 256Mi memory
  - Limits: 500m CPU, 512Mi memory

#### Frontend
- **Technology**: React + Nginx
- **Replicas**: 2
- **Resources**:
  - Requests: 100m CPU, 128Mi memory
  - Limits: 200m CPU, 256Mi memory

## Data Layer

### Cloud SQL
- **Database**: PostgreSQL 15
- **Configuration**: Regional (HA)
- **Tier**: db-custom-2-7680
- **Features**:
  - Point-in-time recovery
  - Automated backups (30 days)
  - Private IP only
  - SSL required

### BigQuery
- **Datasets**: Analytics data
- **Tables**:
  - `events`: Partitioned by day, clustered
  - `metrics`: Time-series data
- **Features**:
  - 90-day table expiration
  - Streaming inserts
  - Optimized for analytics

### Cloud Storage
- **Buckets**:
  - `app-data`: Application data (Standard)
  - `backups`: Backup storage (Nearline)
  - `logs`: Log storage (7-day retention)
  - `artifacts`: CI/CD artifacts
- **Features**:
  - Lifecycle policies
  - Versioning enabled
  - Uniform bucket-level access

## Messaging

### Pub/Sub
- **Topics**:
  - `events`: Application events
  - `notifications`: User notifications
  - `dead-letter`: Failed messages
- **Features**:
  - At-least-once delivery
  - Message retention: 7 days
  - Dead letter queue
  - Retry policies

## Security

### IAM & Workload Identity
- **Service Accounts**: Per-service isolation
- **Workload Identity**: No static credentials
- **Permissions**: Principle of least privilege
- **Features**:
  - GKE to GCP service authentication
  - Service-to-service security
  - Secret management with Secret Manager

### Network Security
- **Private Clusters**: No public endpoints
- **Cloud Armor**: DDoS protection
- **Binary Authorization**: Container signing
- **Network Policies**: Pod-to-pod security

## Observability

### Monitoring
- **Cloud Monitoring**: Infrastructure metrics
- **Custom Dashboards**: Application KPIs
- **Alert Policies**:
  - High CPU (>80%)
  - High Memory (>85%)
  - Pod restarts (>5/10min)
  - API latency (>500ms)
  - Error rate (>5%)

### Logging
- **Cloud Logging**: Centralized logs
- **Log Retention**: 30 days
- **Log Sinks**: Export to BigQuery
- **Structured Logging**: JSON format

### Tracing
- **Cloud Trace**: Distributed tracing
- **OpenTelemetry**: Instrumentation
- **Integration**: All services traced

### SLOs
- **API Availability**: 99.9% uptime
- **Response Time**: <100ms (p95)
- **Error Rate**: <0.1%

## CI/CD Pipeline

### Cloud Build
1. **Test**: Run unit/integration tests
2. **Build**: Create container images
3. **Scan**: Security vulnerability scanning
4. **Push**: Push to Artifact Registry
5. **Deploy**: Deploy to GKE
6. **Verify**: Health checks

### Cloud Deploy
- **Environments**: Dev → Staging → Prod
- **Strategies**: Canary (25%, 50%, 75%, 100%)
- **Approval**: Manual approval for prod
- **Rollback**: Automated rollback on failure

## High Availability

### Multi-Region Setup
- **Primary Region**: asia-south1 (Mumbai, India)
- **Secondary Region**: asia-southeast1 (Singapore)
- **Failover**: Automatic with health checks
- **RTO**: 5 minutes
- **RPO**: 1 minute

### Data Replication
- **Cloud SQL**: Automatic replica
- **BigQuery**: Multi-regional
- **Cloud Storage**: Geo-redundant

## Disaster Recovery

### Backup Strategy
- **Database**: Daily automated backups
- **Configuration**: Infrastructure as Code
- **Data**: Versioned in Cloud Storage
- **Retention**: 30 days

### Recovery Procedures
1. Detect failure (monitoring alerts)
2. Failover to secondary region
3. Restore from backup if needed
4. Verify service health
5. Post-mortem analysis

## Cost Optimization

### Strategies
- **Auto-scaling**: Scale based on demand
- **Committed Use**: Reserved instances
- **Lifecycle Policies**: Archive old data
- **Right-sizing**: Optimal resource allocation
- **Preemptible VMs**: For batch workloads

## Scalability

### Horizontal Scaling
- **GKE**: HPA based on CPU/memory
- **Cloud SQL**: Read replicas
- **Load Balancing**: Global distribution

### Vertical Scaling
- **Node Pools**: Larger machine types
- **Database**: Higher tiers available

## Compliance & Governance

### Standards
- **Security**: SOC 2, ISO 27001
- **Privacy**: GDPR compliant
- **Auditing**: Cloud Audit Logs

### Policies
- **Resource Tagging**: All resources labeled
- **Cost Allocation**: Per-service tracking
- **Access Control**: RBAC enforced

---

This architecture provides enterprise-grade reliability, security, and scalability for production workloads on Google Cloud Platform.
