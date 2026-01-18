from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import logging
from google.cloud import pubsub_v1, storage, bigquery, aiplatform
import vertexai
from vertexai.generative_models import GenerativeModel
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
import os
from datetime import datetime
import uuid
import requests

# Initialize FastAPI app
app = FastAPI(
    title="GCP Platform API",
    description="Production-grade API service on GCP",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# GCP clients
publisher = pubsub_v1.PublisherClient()
storage_client = storage.Client()
bq_client = bigquery.Client()

# Environment variables
PROJECT_ID = os.getenv("GCP_PROJECT_ID", "your-project-id")
PUBSUB_TOPIC = os.getenv("PUBSUB_TOPIC", "gcp-platform-events-prod")
BQ_DATASET = os.getenv("BQ_DATASET", "gcp_platform_prod")
REGION = os.getenv("GCP_REGION", "asia-south1")
VERTEX_REGION = "us-central1"  # Vertex AI region with better model support

# Initialize Vertex AI
vertexai.init(project=PROJECT_ID, location=VERTEX_REGION)
gemini_model = GenerativeModel("gemini-2.0-flash-exp")

# Pydantic models
class Event(BaseModel):
    event_type: str
    user_id: Optional[str] = None
    data: dict

class HealthResponse(BaseModel):
    status: str
    timestamp: datetime
    version: str

class EventResponse(BaseModel):
    event_id: str
    message: str

# Health check endpoint
@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint for load balancer"""
    return HealthResponse(
        status="healthy",
        timestamp=datetime.utcnow(),
        version="1.0.0"
    )

# Readiness check
@app.get("/ready")
async def readiness_check():
    """Readiness check for Kubernetes"""
    return {"status": "ready"}

# Liveness check
@app.get("/live")
async def liveness_check():
    """Liveness check for Kubernetes"""
    return {"status": "alive"}

# Create event endpoint
@app.post("/events", response_model=EventResponse)
async def create_event(event: Event):
    """
    Create a new event and publish to Pub/Sub
    """
    try:
        event_id = str(uuid.uuid4())
        
        # Publish to Pub/Sub
        topic_path = publisher.topic_path(PROJECT_ID, PUBSUB_TOPIC)
        event_data = {
            "event_id": event_id,
            "event_type": event.event_type,
            "user_id": event.user_id,
            "timestamp": datetime.utcnow().isoformat(),
            "data": event.data
        }
        
        message_json = str(event_data).encode("utf-8")
        future = publisher.publish(topic_path, message_json)
        future.result()
        
        logger.info(f"Event {event_id} published to Pub/Sub")
        
        # Insert to BigQuery
        table_id = f"{PROJECT_ID}.{BQ_DATASET}.events"
        rows_to_insert = [{
            "event_id": event_id,
            "event_type": event.event_type,
            "user_id": event.user_id,
            "event_timestamp": datetime.utcnow().isoformat(),
            "event_data": str(event.data)
        }]
        
        errors = bq_client.insert_rows_json(table_id, rows_to_insert)
        if errors:
            logger.error(f"BigQuery insert errors: {errors}")
        
        return EventResponse(
            event_id=event_id,
            message="Event created successfully"
        )
        
    except Exception as e:
        logger.error(f"Error creating event: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Get events endpoint
@app.get("/events")
async def get_events(limit: int = 10):
    """
    Retrieve recent events from BigQuery
    """
    try:
        query = f"""
            SELECT event_id, event_type, user_id, event_timestamp
            FROM `{PROJECT_ID}.{BQ_DATASET}.events`
            ORDER BY event_timestamp DESC
            LIMIT {limit}
        """
        
        query_job = bq_client.query(query)
        results = query_job.result()
        
        events = []
        for row in results:
            events.append({
                "event_id": row.event_id,
                "event_type": row.event_type,
                "user_id": row.user_id,
                "timestamp": row.event_timestamp
            })
        
        return {"events": events, "count": len(events)}
        
    except Exception as e:
        logger.error(f"Error retrieving events: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Metrics endpoint
@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return {"message": "Metrics endpoint - integrate with Prometheus"}

# Chat request model
class ChatRequest(BaseModel):
    message: str

# Chat endpoint with Vertex AI
@app.post("/chat")
async def chat(request: ChatRequest):
    """
    Chat endpoint using Vertex AI Gemini to answer questions about infrastructure
    """
    try:
        # Gather infrastructure context
        context_parts = []
        
        # 1. Get worker service metrics
        try:
            worker_response = requests.get("http://34.47.246.239/metrics", timeout=5)
            if worker_response.status_code == 200:
                worker_data = worker_response.json()
                context_parts.append(f"Worker Service Status:\n- Total messages processed: {worker_data.get('total_processed', 'N/A')}\n- Total errors: {worker_data.get('total_errors', 'N/A')}\n- Last message time: {worker_data.get('last_message_time', 'N/A')}\n- Service status: {worker_data.get('status', 'N/A')}")
        except Exception as e:
            context_parts.append(f"Worker Service: Unable to fetch metrics ({str(e)})")
        
        # 2. Get API service health
        try:
            api_health_response = requests.get("http://localhost:8080/health", timeout=2)
            if api_health_response.status_code == 200:
                context_parts.append("API Service Status: Healthy and operational")
        except Exception:
            context_parts.append("API Service Status: Running (self)")
        
        # 3. Add infrastructure overview
        context_parts.append("""
Infrastructure Overview:
- Platform: Google Cloud Platform
- Project: gcloud-platform-484321
- Regions: asia-south1 (Mumbai), asia-southeast1 (Singapore)
- Services:
  * Portal Dashboard: http://35.244.59.139 (Next.js 14 with real-time health monitoring)
  * API Service: http://34.47.232.24/docs (FastAPI with Vertex AI integration)
  * Worker Service: http://34.47.246.239/metrics (Pub/Sub message processor)
  * Frontend Chat: AI-powered infrastructure assistant
  
- GKE Clusters: 2 regional clusters (primary and secondary)
- Cloud SQL: PostgreSQL with read replica
- BigQuery: Data warehouse with events dataset
- Pub/Sub: Event streaming with gcp-platform-events-prod topic
- Cloud Storage: 4 buckets for different purposes
- Networking: VPC with Cloud NAT and Load Balancers
""")
        
        # Combine all context
        full_context = "\n\n".join(context_parts)
        
        # Build prompt for Gemini
        prompt = f"""You are an AI assistant for a Google Cloud Platform infrastructure. 
You help users understand and monitor their infrastructure by answering questions based on real-time data.

Current Infrastructure State:
{full_context}

User Question: {request.message}

Please provide a helpful, concise answer based on the infrastructure data above. If the question is about specific metrics or status, reference the actual data. If you don't have enough information, say so clearly."""

        # Call Vertex AI Gemini
        response = gemini_model.generate_content(prompt)
        
        return {
            "response": response.text,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Chat error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
