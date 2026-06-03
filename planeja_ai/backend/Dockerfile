# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and group (system user, no shell, no home directory)
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install python dependencies
COPY --chown=root:root --chmod=444 requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy only the files strictly required to run the application (no wildcard COPY)
COPY --chown=root:root --chmod=444 main.py /app/

# Switch to the non-root user
USER appuser

# Expose port 8000 for FastAPI
EXPOSE 8000

# Command to run uvicorn server (assuming main.py contains the FastAPI app named app)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
