
# Use an official Python image
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Copy dependency requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy Flask application
COPY app.py .

# Document application port
EXPOSE 5000

# Start Flask application
CMD ["python", "app.py"]
