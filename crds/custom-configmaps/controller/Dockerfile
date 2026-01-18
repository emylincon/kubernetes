FROM python

# Set the working directory in the container
WORKDIR /app

# Environment variables
ENV NAMESPACE=default
ENV CONFIG_TYPE=incluster

# Copy the Python script into the container
COPY main.py .

# Install required dependencies
RUN pip install kubernetes

# Run the Python script
CMD ["python", "main.py"]