pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'ls -alh'
                sh 'docker build -f Dockerfile.alpine -t turbointegrations/base:latest .'
                sh 'docker build -f Dockerfile.alpine -t turbointegrations/base:0.2-alpine .'
                sh 'docker build -f Dockerfile.slim-buster -t turbointegrations/base:0.2-slim-buster .'
                sh 'docker build -f Dockerfile.rhel -t turbointegrations/base:0.2-rhel .'
            }
        }

        stage('Publish') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'DHPASS', usernameVariable: 'DHUSER')]) {
                    sh 'docker login -u $DHUSER -p $DHPASS'
                    sh 'docker push turbointegrations/base:latest'
                    sh 'docker push turbointegrations/base:0.2-alpine'
                    sh 'docker push turbointegrations/base:0.2-slim-buster'
                    sh 'docker push turbointegrations/base:0.2-rhel'
                }
            }
        }
    }
}
