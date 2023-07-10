pipeline {
    agent any
    
    environment {
        deploy_ip = credentials('deployip')
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
        stage('Deploy) {
            steps {
                sh 'ssh -t ubuntu@${deploy_ip} "./deploy.sh"'
            }
        }
    }
    
post {
        always {
                sh 'docker-compose down'
        }
        success {
                slackSend ( channel: '#general', token: '<secret-token>', message: "Pipeline ran successfully!")
        }
        failure {
                slackSend( channel: "#general", token: '<secret-token>', message: "Test failed!, please watch the logs")
        }
}
}

