pipeline {
    agent any
    
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
        
        stage('Clean') {
            steps {
                sh 'docker-compose down'
            }
        }
       
        stage('Push') {
            steps { 
              dir('/home/ubuntu/workspace/nodeapp') {
                sh 'cat /home/ubuntu/docker.txt | docker login -u ${dockeruser} --password-stdin'
                sh 'docker build -t ${APP} .'
                sh 'docker tag ${APP} ${REPO}/${APP}:${env.BUILD_NUMBER}'
                sh 'docker push ${REPO}/${APP}:${env.BUILD_NUMBER}'
             }
        }
        }
        stage('Deploy') {
            steps {
                sh 'ssh -t ubuntu@${deploy_ip} "./deploy.sh"'
            }
        }
    }
    
post {
        success {
                slackSend ( channel: '#general', token: '<secret-token>', message: "Pipeline ran successfully!")
        }
        failure {
                slackSend( channel: "#general", token: '<secret-token>', message: "Test failed!, please watch the logs")
        }
}
}

