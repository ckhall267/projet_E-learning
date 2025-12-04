FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ ./src/
COPY experiments/ ./experiments/

# Create necessary directories
RUN mkdir -p data/raw data/processed experiments/best_models

# Expose API port
EXPOSE 8000

# Set environment variables
ENV PYTHONPATH=/app
ENV MODEL_DIR=/app/experiments/best_models

# Run the API
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000"]

