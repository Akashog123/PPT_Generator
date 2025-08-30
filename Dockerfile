# Use an official Python image
FROM python:3.11-slim

# Use a standard runtime PORT environment (Railway and other platforms provide PORT)
ENV PORT=8080

# Set working directory
WORKDIR /app

# Install minimal system dependencies for Pillow (libjpeg, zlib) and clean apt lists
RUN apt-get update && apt-get install -y --no-install-recommends libjpeg-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first to leverage Docker layer caching
COPY requirements.txt /app/

# Install Python dependencies as root (before switching to non-root user)
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project files
COPY . /app

# Create a non-root user and chown the app directory
RUN useradd --create-home --shell /bin/false appuser && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the application port (runtime binds to $PORT)
EXPOSE 8080

# Healthcheck uses PORT with default fallback
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD curl -f http://localhost:${PORT:-8080}/healthz || exit 1

# Use shell form so $PORT expands at runtime
CMD ["sh","-c","gunicorn -b 0.0.0.0:${PORT:-8080} app:app"]