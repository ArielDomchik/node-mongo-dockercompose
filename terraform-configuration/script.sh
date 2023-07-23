#!/bin/bash
# Install docker
sudo apt-get update
sudo apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker ubuntu

# Install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


# Create the docker-compose.yml file
cat <<EOF > /home/ubuntu/docker-compose.yml
version: '3'
services:
  node:
    restart: always
    image: arieldomchik/nodeapp:latest
    container_name: nodeapp
    ports:
      - 3000:3000
  mongo:
    image: mongo
    container_name: mongodb-container
    ports:
      - 27017:27017
    volumes:
      - mongodb:/data/db
volumes:
 mongodb:
EOF

# Start the Docker containers
cd /home/ubuntu/ && docker compose up --build -d
