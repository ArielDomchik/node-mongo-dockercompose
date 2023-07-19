pipeline {
    agent { label 'Slave 1' }
    
    environment {
        dockeruser = credentials('dockeruser')
        deploy_ip = credentials('deployip')
        REPO = 'arieldomchik'
        APP = 'nodeapp'
    }

    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'docker-compose up --build -d'
            }
        }
        
        stage('Test') {
            steps {
                sh 'echo "tests will be inserted here"'
            }
        }
        
        stage('Push') {
           steps {
               sh 'cat /home/ubuntu/docker.txt | docker login -u ${dockeruser} --password-stdin'
               sh 'docker build -t ${REPO}/${APP}:latest .' 
               sh 'docker push ${REPO}/${APP}:latest'
           }
        }

        stage('Clean') {
            steps {
                sh 'docker-compose down'
                
            }
       }
        stage('Deploy') {
            steps {
                sh 'ssh ubuntu@${deploy_ip} "docker compose down"'
                sh 'ssh ubuntu@${deploy_ip} "docker-compose up --build -d"'
               }
            }
        }
    }
