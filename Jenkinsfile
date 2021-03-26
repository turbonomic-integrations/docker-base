def tag="turbointegrations/base"
def latest_flavor="alpine"
def flavors="alpine,slim-buster,rhel"
def tracked_modules=["vmtconnect","vmtplan","umsg","dateutils","pyyaml"]

pipeline {
    agent { label 'linux && mavenpod' } 
    triggers { cron('0 0 * * *') }
    stages {
        stage('Build') {
            steps {
                sh 'git checkout $BRANCH_NAME'
                load './VERSION'
                script {
                    env.FROM_VERSION = "${MAJOR}.${MINOR}.${PATCH}"
                    flavors.split(',').each {
                        sh "docker build --no-cache -f src/docker/Dockerfile.${it} -t ${tag}:${it}-build ."
                    }
                }
            }
        }

        stage('Version Increment Check') {
            steps {
                load "VERSION"
                script {
                    env.FROM_VERSION="${MAJOR}.${MINOR}.${PATCH}"
                    FIRST_RUN=(!fileExists("manifest.${latest_flavor}"))
                    auto_versions = []
                    if (!FIRST_RUN) {
                        flavors.split(',').each {
                            sh "mv manifest.${it} previous-manifest.${it}"
                        }
                    }

                    flavors.split(',').each {
                        base_tag = sh(returnStdout: true, script: "cat src/docker/Dockerfile.${it} | head -1").trim()
                        base_tag = base_tag.split(' ').last()
                        echo "Base Tag is ${base_tag}"
                        // No idea why I can't simply redirect to manifest.${it} directly, but.. here we are
                        manifest = sh(returnStdout: true, script: "docker inspect --format='{{index .RepoDigests 0}}' ${base_tag}").trim()+'\n'
                        manifest += sh(returnStdout: true, script: "docker run --rm -i --entrypoint /bin/sh ${tag}:${it}-build -c \"python --version\"").trim()+'\n'
                        manifest += sh(returnStdout: true, script: "docker run --rm -i --entrypoint /bin/sh ${tag}:${it}-build -c \"pip -V\"").trim()+'\n'
                        modules = sh(returnStdout: true, script: "docker run --rm -i --entrypoint /bin/sh ${tag}:${it}-build -c \"pip freeze\"").trim()

                        inspect_modules = modules.split('\n').findAll { m ->
                            tracked_modules.any { m.toLowerCase().contains(it) }
                        }

                        manifest += inspect_modules.join('\n')

                        echo manifest
                        writeFile file: "manifest.${it}", text: manifest
                    }

                    if (!FIRST_RUN) {
                        flavors.split(',').each {
                            prev_len = sh(returnStdout: true, script: "wc -l < previous-manifest.${it}") as Integer
                            cur_len = sh(returnStdout: true, script: "wc -l < manifest.${it}") as Integer
                            diff_out = sh(returnStatus: true, script: "diff previous-manifest.${it} manifest.${it}") as Integer

                            if (prev_len > cur_len) {
                                auto_versions << "MAJOR"
                            } else if (prev_len < cur_len) {
                                auto_versions << "MINOR"
                            } else if (diff_out) {
                                auto_versions << "PATCH"
                            } else {
                                auto_versions << "NONE"
                            }
                        }
                        if (auto_versions.unique(false).size() > 1) {
                            flavors.split(',').eachWithIndex { flavor, idx ->
                                echo "${flavor} incremented: ${auto_versions[idx]}"
                            }
                            error "Detected different versioning increments for one or more images. This suggests that one of them is out of sync. Manual intervention required"
                        }
                        changetype = auto_versions.unique(false).first()
                        switch(changetype) {
                            case "MAJOR": MAJOR++; MINOR=0; PATCH=0; break;
                            case "MINOR": MINOR++; PATCH=0; break;
                            case "PATCH": PATCH++; break;
                        }
                        writeFile file: 'VERSION', text: """MAJOR=${MAJOR}
MINOR=${MINOR}
PATCH=${PATCH}"""
                    }
                    load "VERSION"
                    env.TO_VERSION="${MAJOR}.${MINOR}.${PATCH}"
                    env.TO_MAJMINVER="${MAJOR}.${MINOR}"
                    PROCEED = env.FROM_VERSION != env.TO_VERSION
                }
                echo "Version advancement ${env.FROM_VERSION} -> ${env.TO_VERSION}"
            }
        }

        stage('Publish') {
            when {
                expression { FIRST_RUN || PROCEED }
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
                expression { FIRST_RUN || PROCEED }
            }
            steps {
                sh('''
                    git config user.name 'JenkinsAutomation'
                    git config user.email 'ae-integration@vmturbo.com'
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
