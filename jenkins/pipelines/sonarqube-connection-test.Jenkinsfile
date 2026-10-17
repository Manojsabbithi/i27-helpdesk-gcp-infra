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

                        echo "===== SONARQUBE ====="
                        echo "Server: ${SONAR_HOST_URL}"

                        curl -fsS \
                          "${SONAR_HOST_URL}/api/system/status"

                        echo
                        echo
                        echo "===== ADMIN PERMISSION CHECK ====="

                        set +x

                        HTTP_CODE="$(
                          curl -sS \
                            -o /tmp/sonar-admin-check.json \
                            -w "%{http_code}" \
                            -u "${SONAR_AUTH_TOKEN}:" \
                            "${SONAR_HOST_URL}/api/permissions/search_templates?p=1&ps=1"
                        )"

                        set -x

                        echo "Admin API HTTP status: ${HTTP_CODE}"

                        if [ "${HTTP_CODE}" = "200" ]; then
                            echo "SONAR ADMIN TOKEN: YES"
                        else
                            echo "SONAR ADMIN TOKEN: NO"
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
}
