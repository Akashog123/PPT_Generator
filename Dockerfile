# Use a lightweight Python base image
FROM python:3.10-slim

# Install system packages required for Pillow (and python-pptx)
RUN apt-get update && apt-get install -y \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libopenjp2-7 \
    libtiff5 \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy your app's code and requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your app
COPY . .

# Create the upload folder for Vercel compatibility
RUN mkdir -p /tmp/uploads

# Expose port (Vercel expects 8000 by default)
EXPOSE 8000

# Command to run your Flask app with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:application"]
