# #!/bin/bash
# # Update and install Python3, pip, etc.
# apt update -y
# apt install -y python3-pip

# # Navigate to home directory
# cd /home/ubuntu

# # Create FastAPI application
# cat <<EOF > main.py
# from fastapi import FastAPI

# app = FastAPI()

# @app.get("/")
# def root():
#     return {"message": "Hello from FastAPI on Ubuntu EC2!!!!"}
# EOF

# # Install FastAPI and Uvicorn
# pip3 install fastapi uvicorn

# # Run the FastAPI app on port 80 in background
# sudo nohup uvicorn main:app --host 0.0.0.0 --port 8000 &

#!/bin/bash

# Update packages and install required software

apt update -y
apt install -y git python3-pip

# Clone Bitbucket repo (public repo example)
cd /home/ubuntu
git clone https://bitbucket.org/thoibi3/FastApiEc2.git app
cd app

# Install FastAPI and Uvicorn
pip3 install fastapi uvicorn

# Start FastAPI in background on port 80
nohup uvicorn main:app --host 0.0.0.0 --port 80 > fastapi.log 2>&1 &
