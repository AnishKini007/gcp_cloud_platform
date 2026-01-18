FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 workeruser && chown -R workeruser:workeruser /app
USER workeruser

CMD ["python", "worker.py"]
