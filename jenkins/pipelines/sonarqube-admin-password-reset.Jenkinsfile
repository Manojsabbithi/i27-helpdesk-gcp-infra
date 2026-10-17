pipeline {
    agent {
        label 'i27-helpdesk-agent'
    }

    stages {
        stage('Reset SonarQube Admin Password') {
            steps {
                withSonarQubeEnv('i27-sonarqube') {
                    withCredentials([
                        string(
                            credentialsId: 'sonarqube-admin-new-password',
                            variable: 'NEW_SONAR_PASSWORD'
                        )
                    ]) {
                        sh '''
                            set -e
                            set +x

                            echo "===== SONARQUBE ADMIN PASSWORD RESET ====="

                            HTTP_CODE="$(
                              curl -sS \
                                -o /tmp/sonar-password-reset.out \
                                -w "%{http_code}" \
                                -X POST \
                                -H "Authorization: Bearer ${SONAR_AUTH_TOKEN}" \
                                --data-urlencode "login=admin" \
                                --data-urlencode "password=${NEW_SONAR_PASSWORD}" \
                                "${SONAR_HOST_URL}/api/users/change_password"
                            )"

                            echo "HTTP status: ${HTTP_CODE}"

                            if [ "${HTTP_CODE}" != "204" ] && \
                               [ "${HTTP_CODE}" != "200" ]; then
                                echo "Password reset failed."
                                cat /tmp/sonar-password-reset.out
                                exit 1
                            fi

                            echo "SonarQube admin password reset SUCCESS."
                        '''
                    }
                }
            }
        }
    }
}
