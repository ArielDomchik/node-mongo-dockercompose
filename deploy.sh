docker pull arieldomchik/nodeapp:${env.BUILD_NUMBER}

docker-compose down
docker-compose build --up -d
