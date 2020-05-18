pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/turbo-integrations/docker-base.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'ls -alh'
                sh 'docker build -t turbointegrations/base:latest .'
            }
        }
        
        stage('Publish') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'DHPASS', usernameVariable: 'DHUSER')]) {
                    sh 'docker login -u $DHUSER -p $DHPASS'
                    sh 'docker push turbointegrations/base:latest'
                }
            }
        }
    }
}
