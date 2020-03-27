pipeline {
    agent { label 'nixbld' }
    stages {
        stage('Build Docker image') {
            steps {
                script {
                    dockerImage = nixBuildDocker (nixFile: "docker.nix",
                                                  namespace: "utils",
                                                  name: "nix-ipmi",
                                                  currentProjectBranch: GIT_BRANCH)
                }
            }
        }
        stage('Push Docker image') {
            steps {
                pushDocker image: dockerImage, pushToBranchName: false
            }
        }
    }
    post {
        success { cleanWs() }
        failure { notifySlack "Build failled: ${JOB_NAME} [<${RUN_DISPLAY_URL}|${BUILD_NUMBER}>]", "red" }
    }
}
