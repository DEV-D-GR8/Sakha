# Use an official Python runtime as a parent image.
FROM python:3.9-slim

# Set environment variables for production
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y gcc netcat

# Install pip requirements
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project
COPY . .

# Collect static files if needed (assuming you have static files)
RUN python manage.py collectstatic --noinput

# Expose the port (adjust if necessary)
EXPOSE 8000

# Start Gunicorn server
CMD ["gunicorn", "sakha_backend.wsgi:application", "--bind", "0.0.0.0:8000"]
