pipeline {
    agent {
        label 'i27-helpdesk-agent'
    }

    stages {
        stage('Create SonarQube Recovery Admin') {
            steps {
                withSonarQubeEnv('i27-sonarqube') {
                    withCredentials([
                        string(
                            credentialsId: 'sonarqube-admin-new-password',
                            variable: 'RECOVERY_PASSWORD'
                        )
                    ]) {
                        sh '''
                            set -e
                            set +x

                            RECOVERY_USER="i27-recovery-admin"

                            echo "===== CREATE RECOVERY USER ====="

                            CREATE_CODE="$(
                              curl -sS \
                                -o /tmp/sonar-create-user.out \
                                -w "%{http_code}" \
                                -u "${SONAR_AUTH_TOKEN}:" \
                                -X POST \
                                --data-urlencode "login=${RECOVERY_USER}" \
                                --data-urlencode "name=i27 Recovery Admin" \
                                --data-urlencode "password=${RECOVERY_PASSWORD}" \
                                "${SONAR_HOST_URL}/api/users/create"
                            )"

                            echo "Create user HTTP status: ${CREATE_CODE}"

                            if [ "${CREATE_CODE}" != "200" ]; then
                                cat /tmp/sonar-create-user.out
                                exit 1
                            fi

                            echo
                            echo "===== GRANT SYSTEM ADMIN ====="

                            ADMIN_CODE="$(
                              curl -sS \
                                -o /tmp/sonar-admin-grant.out \
                                -w "%{http_code}" \
                                -u "${SONAR_AUTH_TOKEN}:" \
                                -X POST \
                                --data-urlencode "login=${RECOVERY_USER}" \
                                --data-urlencode "permission=admin" \
                                "${SONAR_HOST_URL}/api/permissions/add_user"
                            )"

                            echo "Grant admin HTTP status: ${ADMIN_CODE}"

                            if [ "${ADMIN_CODE}" != "204" ] && \
                               [ "${ADMIN_CODE}" != "200" ]; then
                                cat /tmp/sonar-admin-grant.out
                                exit 1
                            fi

                            echo
                            echo "===== VALIDATE RECOVERY LOGIN ====="

                            VALIDATION="$(
                              curl -sS \
                                -u "${RECOVERY_USER}:${RECOVERY_PASSWORD}" \
                                "${SONAR_HOST_URL}/api/authentication/validate"
                            )"

                            echo "${VALIDATION}"

                            echo "${VALIDATION}" | grep -q '"valid":true'

                            echo
                            echo "===== VALIDATE ADMIN PERMISSION ====="

                            PERMISSION_CODE="$(
                              curl -sS \
                                -o /tmp/sonar-recovery-admin-check.out \
                                -w "%{http_code}" \
                                -u "${RECOVERY_USER}:${RECOVERY_PASSWORD}" \
                                "${SONAR_HOST_URL}/api/permissions/search_templates?p=1&ps=1"
                            )"

                            echo "Recovery admin API HTTP status: ${PERMISSION_CODE}"

                            if [ "${PERMISSION_CODE}" != "200" ]; then
                                exit 1
                            fi

                            echo
                            echo "RECOVERY ADMIN READY"
                        '''
                    }
                }
            }
        }
    }
}
