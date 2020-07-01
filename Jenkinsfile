def tag="turbointegrations/base"
def latest_flavor="alpine"
def flavors="alpine,slim-buster,rhel"

pipeline {
    agent any
    triggers { cron('0 0 * * *') }
    stages {
        stage('Build') {
            steps {
                sh 'git checkout $BRANCH_NAME'
                load './VERSION'
                script {
                    env.FROM_VERSION = "${MAJOR}.${MINOR}.${PATCH}"
                    flavors.split(',').each {
                        sh "docker build -f src/docker/Dockerfile.${it} -t ${tag}:${it}-build ."
                    }
                }
            }
        }

        stage('Version Increment Check') {
            steps {
                sh 'bin/manifests.sh'
                load './VERSION'
                script {
                    env.TO_VERSION = "${MAJOR}.${MINOR}.${PATCH}"
                    env.TO_MAJMINVER = "${MAJOR}.${MINOR}"
                    PROCEED = (! fileExists('previous-manifest.alpine') || env.FROM_VERSION != env.TO_VERSION)
                }
                echo "Version increment ${env.FROM_VERSION} -> ${env.TO_VERSION}"
            }
        }

        stage('Publish') {
            when {
                expression { PROCEED }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'DHPASS', usernameVariable: 'DHUSER')]) {
                    sh 'docker login -u $DHUSER -p $DHPASS'

                    // Tag and push latest
                    sh "docker tag ${tag}:${latest_flavor}-build ${tag}:latest"
                    sh "docker push ${tag}:latest"

                    // Tag and push all flavors
                    script {
                        flavors.split(',').each {
                          sh "docker tag ${tag}:${it}-build ${tag}:$TO_VERSION-${it}"
                          sh "docker tag ${tag}:${it}-build ${tag}:$TO_MAJMINVER-${it}"
                          sh "docker tag ${tag}:${it}-build ${tag}:$MAJOR-${it}"

                          sh "docker push ${tag}:$TO_VERSION-${it}"
                          sh "docker push ${tag}:$TO_MAJMINVER-${it}"
                          sh "docker push ${tag}:$MAJOR-${it}"
                        }
                    }
                }
            }
        }

        stage('Commit') {
            when {
                expression { PROCEED }
            }
            steps {
                sh('''
                    git config user.name 'JenkinsAutomation'
                    git config user.email 'ae-integration@turbonomic.com'
                    git add VERSION
                    git add manifest.*
                    git commit -m "Jenkins automated release of $TO_VERSION"
                    git tag $TO_VERSION
                ''')

                sshagent(['TurbonomicIntegrationsGitDeployKey']) {
                    sh("""
                      #!/usr/bin/env bash
                      set +x
                      export GIT_SSH_COMMAND="ssh -oStrictHostKeyChecking=no"
                      git push origin $BRANCH_NAME
                      git push --tags
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
