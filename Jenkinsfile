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
        
        stage('Clean') {
            steps {
                sh 'docker-compose down'
            }
        }
       
        stage('Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ariel', keyFileVariable: 'SSH_KEY')]) {
            sh "ssh -i $SSH_KEY ubuntu@${deploy_ip} './deploy.sh'"
        }
    }
}
    }
    
    post {
        success {
            slackSend (channel: '#general', token: '<secret-token>', message: "Pipeline ran successfully!")
        }
        failure {
            slackSend (channel: "#general", token: '<secret-token>', message: "Test failed! Please watch the logs.")
        }
    }
}
