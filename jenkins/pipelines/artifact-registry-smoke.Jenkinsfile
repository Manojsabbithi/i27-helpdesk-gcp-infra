pipeline {
    agent {
        label 'i27-helpdesk-agent'
    }

    environment {
        REGISTRY_HOST = 'asia-south1-docker.pkg.dev'
        PROJECT_ID    = 'i27-helpdesk-gcp-dev-lab'
        REPOSITORY    = 'i27-helpdesk-dev-auth-service'
    }

    stages {

        stage('Verify Agent') {
            steps {
                sh '''
                    echo "===== HOST ====="
                    hostname

                    echo
                    echo "===== USER ====="
                    whoami

                    echo
                    echo "===== GCP SERVICE ACCOUNT ====="

                    curl -fsS \
                      -H "Metadata-Flavor: Google" \
                      http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email

                    echo
                '''
            }
        }

        stage('Build Smoke Image') {
            steps {
                sh '''
                    rm -rf registry-smoke
                    mkdir registry-smoke

                    cat > registry-smoke/Dockerfile <<'DOCKERFILE'
FROM alpine:3.20

RUN adduser -D appuser
USER appuser

CMD ["sh", "-c", "echo Artifact Registry smoke test passed"]
DOCKERFILE

                    IMAGE_URI="${REGISTRY_HOST}/${PROJECT_ID}/${REPOSITORY}/registry-smoke:build-${BUILD_NUMBER}"

                    echo "${IMAGE_URI}" > image-uri.txt

                    docker build \
                      -t "${IMAGE_URI}" \
                      registry-smoke
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                    IMAGE_URI="$(cat image-uri.txt)"

                    docker push "${IMAGE_URI}"
                '''
            }
        }

        stage('Verify Artifact Registry') {
            steps {
                sh '''
                    IMAGE_URI="$(cat image-uri.txt)"

                    echo "===== VERIFY REMOTE IMAGE ====="
                    echo "${IMAGE_URI}"

                    docker image rm "${IMAGE_URI}" || true

                    echo
                    echo "===== PULL FROM ARTIFACT REGISTRY ====="

                    docker pull "${IMAGE_URI}"

                    echo
                    echo "===== RUN PULLED IMAGE ====="

                    docker run --rm "${IMAGE_URI}"
                '''
            }
        }
    }

    post {
        success {
            echo 'Artifact Registry smoke test PASSED.'
        }

        failure {
            echo 'Artifact Registry smoke test FAILED.'
        }

        always {
            sh '''
                if [ -f image-uri.txt ]; then
                    docker image rm "$(cat image-uri.txt)" || true
                fi

                rm -rf registry-smoke image-uri.txt
            '''
        }
    }
}
