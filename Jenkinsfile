pipeline {
    agent any

    environment {
        IMAGE_NAME     = 'cicd-demo'
        CONTAINER_NAME = 'cicd-demo'
        HOST_PORT      = '8081'          // page will be at http://<server-ip>:8081
        SHORT_COMMIT   = "${env.GIT_COMMIT ? env.GIT_COMMIT.take(7) : 'unknown'}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --oneline'
            }
        }

        stage('Build image') {
            steps {
                sh """
                  docker build \
                    --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
                    --build-arg GIT_COMMIT=${SHORT_COMMIT} \
                    --build-arg GIT_BRANCH=${env.BRANCH_NAME ?: 'main'} \
                    -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                    -t ${IMAGE_NAME}:latest .
                """
            }
        }

        stage('Smoke test') {
            steps {
                sh """
                  docker rm -f ${CONTAINER_NAME}-test 2>/dev/null || true
                  docker run -d --name ${CONTAINER_NAME}-test -p 18081:80 ${IMAGE_NAME}:${BUILD_NUMBER}
                  sleep 3
                  curl -fsS http://localhost:18081/ | grep -q "Hello from the CI/CD pipeline"
                  curl -fsS http://localhost:18081/build-info.json
                """
            }
            post {
                always { sh "docker rm -f ${CONTAINER_NAME}-test 2>/dev/null || true" }
            }
        }

        stage('Deploy') {
            steps {
                sh """
                  docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
                  docker run -d --name ${CONTAINER_NAME} --restart unless-stopped \
                    -p ${HOST_PORT}:80 ${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }
    }

    post {
        success { echo "Deployed build #${BUILD_NUMBER} -> http://<server-ip>:${HOST_PORT}" }
        failure { echo 'Pipeline failed. Check the stage logs above.' }
        always  { sh 'docker image prune -f || true' }
    }
}
