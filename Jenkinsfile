pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                load './VERSION'
                script {
                    env.FROM_VERSION = "${MAJOR}.${MINOR}.${PATCH}"
                }
                sh 'docker build -f src/docker/Dockerfile.alpine -t turbointegrations/base:alpine-build .'
                sh 'docker build -f src/docker/Dockerfile.slim-buster -t turbointegrations/base:slim-buster-build .'
                sh 'docker build -f src/docker/Dockerfile.rhel -t turbointegrations/base:rhel-build .'
            }
        }

        stage('Version Increment Check') {
            steps {
                sh 'bin/manifests.sh'
                load './VERSION'
                script {
                    env.TO_VERSION = "${MAJOR}.${MINOR}.${PATCH}"
                    env.PROCEED = (env.FROM_VERSION != env.TO_VERSION || ! fileExists('previous-manifest.alpine'))
                }
                echo "Version increment ${env.FROM_VERSION} -> ${env.TO_VERSION}"
            }
        }

        stage('Publish') {
            when {
                expression { env.PROCEED }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'DHPASS', usernameVariable: 'DHUSER')]) {
                    sh 'docker login -u $DHUSER -p $DHPASS'
                    // Tag and push latest & alpine
                    sh 'docker tag turbointegrations/base:alpine-build turbointegrations/base:latest'
                    sh 'docker tag turbointegrations/base:alpine-build turbointegrations/base:$TO_VERSION-alpine'
                    sh 'docker push turbointegrations/base:latest'
                    sh 'docker push turbointegrations/base:$TO_VERSION-alpine'

                    // Tag and push slim-buster
                    sh 'docker tag turbointegrations/base:slim-buster-build turbointegrations/base:$TO_VERSION-slim-buster'
                    sh 'docker push turbointegrations/base:$TO_VERSION-slim-buster'

                    // Tag and push rhel
                    sh 'docker tag turbointegrations/base:rhel-build turbointegrations/base:$TO_VERSION-rhel'
                    sh 'docker push turbointegrations/base:$TO_VERSION-rhel'
                }
            }
        }

        stage('Commit') {
            when {
                expression { env.PROCEED }
            }
            steps {
                sh('''
                    git config user.name 'JenkinsAutomation'
                    git config user.email 'ae-integration@turbonomic.com'
                    git add VERSION
                    git add manifest.*
                    git commit -m 'Jenkins automated release of $TO_VERSION'
                    git tag -a $TO_VERSION -m 'Jenkins automated release of $TO_VERSION'
                ''')

                sshagent(['TurbonomicIntegrationsGitDeployKey']) {
                    sh("""
                      #!/usr/bin/env bash
                      set +x
                      export GIT_SSH_COMMAND="ssh -oStrictHostKeyChecking=no"
                      git push origin $TO_VERSION
                    """)
                }
            }
        }
    }
    post {
        always {
            cleanWs notFailBuild: true
        }
    }
}
