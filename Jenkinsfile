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
               sh 'docker build -t ${REPO}/${APP} .' 
               sh 'docker push ${REPO}/${APP}'
           }
        }

        stage('Clean') {
            steps {
                sh 'docker-compose down'
                
            }
       }
        stage('Deploy') {
            steps {
                dir('/home/ubuntu') {
            sh 'ssh -i "ariel.pem" ubuntu@${deploy_ip} "./deploy.sh"'
        }
    }
}
    }
    
