pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -f src/docker/Dockerfile.alpine -t turbointegrations/base:alpine-build .'
                sh 'docker build -f src/docker/Dockerfile.slim-buster -t turbointegrations/base:slim-buster-build .'
                sh 'docker build -f src/docker/Dockerfile.rhel -t turbointegrations/base:rhel-build .'
            }
        }

        /*stage('Publish') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'DHPASS', usernameVariable: 'DHUSER')]) {
                    sh 'docker login -u $DHUSER -p $DHPASS'
                    sh 'docker push turbointegrations/base:latest'
                    sh 'docker push turbointegrations/base:0.2-alpine'
                    sh 'docker push turbointegrations/base:0.2-slim-buster'
                    sh 'docker push turbointegrations/base:0.2-rhel'
                }
            }
        }*/
    }
}
