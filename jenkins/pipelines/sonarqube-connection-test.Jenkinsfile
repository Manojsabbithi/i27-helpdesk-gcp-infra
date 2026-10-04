pipeline {
    agent {
        label 'i27-helpdesk-agent'
    }

    stages {

        stage('SonarQube Connection') {
            steps {
                withSonarQubeEnv('i27-sonarqube') {
                    sh '''
                        set -e

                        echo "===== SONARQUBE SERVER ====="
                        echo "${SONAR_HOST_URL}"

                        echo
                        echo "===== NETWORK CHECK ====="
                        curl -fsS \
                          --connect-timeout 5 \
                          "${SONAR_HOST_URL}/api/system/status"

                        echo
                        echo
                        echo "===== TOKEN INJECTION ====="

                        if [ -z "${SONAR_AUTH_TOKEN:-}" ]; then
                            echo "ERROR: SonarQube token was not injected."
                            exit 1
                        fi

                        echo "Token injected: YES"

                        echo
                        echo "===== TOKEN VALIDATION ====="

                        set +x

                        AUTH_RESPONSE="$(
                          curl -fsS \
                            -u "${SONAR_AUTH_TOKEN}:" \
                            "${SONAR_HOST_URL}/api/authentication/validate"
                        )"

                        set -x

                        echo "${AUTH_RESPONSE}"

                        echo "${AUTH_RESPONSE}" | grep -q '"valid":true'
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'SonarQube connection test PASSED.'
        }

        failure {
            echo 'SonarQube connection test FAILED.'
        }
    }
}
