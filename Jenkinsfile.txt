
pipeline {
    agent { label 'docker-builder' }

    environment {
        IMAGE_NAME = 'ledwards17/flask-hello-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh '''
                    docker build -t "$IMAGE_NAME:$IMAGE_TAG" \
                                 -t "$IMAGE_NAME:latest" .
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    docker image inspect "$IMAGE_NAME:$IMAGE_TAG"
                    docker run --rm --entrypoint python \
                        "$IMAGE_NAME:$IMAGE_TAG" \
                        -c "import flask; print('Flask test passed')"
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh '''
                        set +x
                        printf '%s' "$DOCKER_TOKEN" |
                            docker login -u "$DOCKER_USER" --password-stdin

                        docker push "$IMAGE_NAME:$IMAGE_TAG"
                        docker push "$IMAGE_NAME:latest"
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Docker build and push successful!'
        }
        failure {
            echo 'Pipeline failed. Check console output.'
        }
    }
}
