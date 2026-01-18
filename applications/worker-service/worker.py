"""
Background Worker Service
Processes events from Pub/Sub and performs background tasks
"""

import os
import logging
import time
import json
from datetime import datetime
from threading import Thread
from http.server import HTTPServer, BaseHTTPRequestHandler
from google.cloud import pubsub_v1, storage, bigquery
from concurrent.futures import TimeoutError

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Environment variables
PROJECT_ID = os.getenv("GCP_PROJECT_ID", "your-project-id")
SUBSCRIPTION_ID = os.getenv("PUBSUB_SUBSCRIPTION", "gcp-platform-events-sub-prod")
TIMEOUT = 300.0  # 5 minutes
HTTP_PORT = int(os.getenv("HTTP_PORT", "8080"))

# GCP clients
subscriber = pubsub_v1.SubscriberClient()
storage_client = storage.Client()
bq_client = bigquery.Client()

# Metrics
metrics = {
    "total_processed": 0,
    "total_errors": 0,
    "last_message_time": None,
    "start_time": datetime.utcnow().isoformat(),
    "status": "running"
}

class HealthHandler(BaseHTTPRequestHandler):
    """Simple HTTP handler for health checks and metrics"""
    
    def do_GET(self):
        if self.path == "/health" or self.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "healthy"}).encode())
        elif self.path == "/metrics":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(metrics).encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

def run_http_server():
    """Run HTTP server for health checks"""
    server = HTTPServer(("0.0.0.0", HTTP_PORT), HealthHandler)
    logger.info(f"HTTP server started on port {HTTP_PORT}")
    server.serve_forever()

def process_message(message):
    """
    Process a single message from Pub/Sub
    """
    try:
        logger.info(f"Processing message: {message.message_id}")
        
        # Decode message data
        data = message.data.decode("utf-8")
        logger.info(f"Message data: {data}")
        
        # Perform background processing
        # Example: Store processed data to Cloud Storage
        bucket_name = f"{PROJECT_ID}-gcp-platform-data-prod"
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(f"processed/{message.message_id}.txt")
        blob.upload_from_string(data)
        
        logger.info(f"Message {message.message_id} processed successfully")
        
        # Update metrics
        metrics["total_processed"] += 1
        metrics["last_message_time"] = datetime.utcnow().isoformat()
        
        # Acknowledge the message
        message.ack()
        
    except Exception as e:
        logger.error(f"Error processing message {message.message_id}: {str(e)}")
        metrics["total_errors"] += 1
        # Nack the message to retry
        message.nack()

def callback(message):
    """Callback function for Pub/Sub messages"""
    process_message(message)

def main():
    """
    Main worker loop
    """
    # Start HTTP server in background thread
    http_thread = Thread(target=run_http_server, daemon=True)
    http_thread.start()
    
    subscription_path = subscriber.subscription_path(PROJECT_ID, SUBSCRIPTION_ID)
    
    logger.info(f"Starting worker service, listening to {subscription_path}")
    
    streaming_pull_future = subscriber.subscribe(
        subscription_path, callback=callback
    )
    
    logger.info(f"Worker listening for messages on {subscription_path}")
    
    # Keep the worker running
    try:
        streaming_pull_future.result()
    except KeyboardInterrupt:
        streaming_pull_future.cancel()
        logger.info("Worker stopped by user")
        metrics["status"] = "stopped"
    except Exception as e:
        logger.error(f"Worker error: {str(e)}")
        metrics["status"] = "error"
        streaming_pull_future.cancel()

if __name__ == "__main__":
    main()
