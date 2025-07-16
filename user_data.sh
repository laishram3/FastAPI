apt update -y
apt install -y git python3-pip

# Clone Bitbucket repo (public repo example)
cd /home/ubuntu
git clone https://bitbucket.org/thoibi3/FastApiEc2.git app
cd app

# Install FastAPI and Uvicorn
pip3 install fastapi uvicorn boto3

# Start FastAPI in background on port 80
# nohup uvicorn main:app --host 0.0.0.0 --port 8000 > fastapi.log 2>&1 &
