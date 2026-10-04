pipeline {
    agent {
        label 'i27-helpdesk-agent'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        PROJECT_ID    = 'i27-helpdesk-gcp-dev-lab'
        REGISTRY_HOST = 'asia-south1-docker.pkg.dev'
        REPOSITORY    = 'i27-helpdesk-dev-auth-service'
        SERVICE       = 'auth-service'
    }

    stages {

        stage('Checkout') {
            steps {
                deleteDir()

                git \
                  branch: 'master',
                  url: 'https://github.com/Manojsabbithi/i27-helpdesk-auth-service.git'

                script {
                    env.GIT_SHORT_SHA = sh(
                        script: 'git rev-parse --short=8 HEAD',
                        returnStdout: true
                    ).trim()

                    env.IMAGE_URI =
                        "${REGISTRY_HOST}/${PROJECT_ID}/${REPOSITORY}/${SERVICE}:${GIT_SHORT_SHA}"
                }

                echo "Commit    : ${GIT_SHORT_SHA}"
                echo "Image URI : ${IMAGE_URI}"
            }
        }

        stage('Build Environment') {
            steps {
                sh '''
                    echo "===== HOST ====="
                    hostname

                    echo "===== USER ====="
                    whoami

                    echo "===== JAVA ====="
                    java -version

                    echo "===== JAVAC ====="
                    javac -version

                    echo "===== MAVEN ====="
                    mvn -version

                    echo "===== DOCKER ====="
                    docker --version
                '''
            }
        }

        stage('Maven Verify') {
            steps {
                sh '''
                    mvn -B -ntp clean verify
                '''
            }
        }

        stage('SonarQube Analysis') {
    	    steps {
                withSonarQubeEnv('i27-sonarqube') {
                    sh '''
                	set -e

                        echo "===== SONARQUBE ANALYSIS ====="
                        echo "Server: ${SONAR_HOST_URL}"

                        echo
                        echo "===== JACOCO REPORT ====="

                        if [ -f target/site/jacoco/jacoco.xml ]; then
                            echo "JaCoCo XML report found."
                            ls -lh target/site/jacoco/jacoco.xml
                        else
                           echo "WARNING: JaCoCo XML report not found."
                        fi

                        echo
                        echo "===== RUN SONAR SCANNER ====="

                        mvn \
                   	  -B \
                   	  -ntp \
                   	  org.sonarsource.scanner.maven:sonar-maven-plugin:5.8.0.7211:sonar \
                   	  -Dsonar.projectKey=i27-helpdesk-auth-service \
                   	  -Dsonar.projectName="i27 Helpdesk Auth Service"
                      '''
            	}
          }

        }
	stage('Docker Build') {
            steps {
                sh '''
                    echo "Building:"
                    echo "${IMAGE_URI}"

                    docker build \
                      -t "${IMAGE_URI}" \
                      .
                '''
            }
        }

        stage('Push Artifact Registry') {
            steps {
                sh '''
                    echo "Pushing:"
                    echo "${IMAGE_URI}"

                    docker push "${IMAGE_URI}"
                '''
            }
        }

        stage('Verify Published Image') {
            steps {
                sh '''
                    echo "===== REMOVE LOCAL IMAGE ====="
                    docker image rm "${IMAGE_URI}" || true

                    echo
                    echo "===== PULL FROM ARTIFACT REGISTRY ====="
                    docker pull "${IMAGE_URI}"

                    echo
                    echo "===== VERIFY IMAGE ====="
                    docker images \
                      --filter "reference=${IMAGE_URI}"
                '''
            }
        }

        stage('Summary') {
            steps {
                echo """
                ========================================
                AUTH SERVICE CI SUCCESS

                Commit : ${GIT_SHORT_SHA}
                Image  : ${IMAGE_URI}
                ========================================
                """
            }
        }
    }

    post {
        success {
            echo 'auth-service CI pipeline PASSED.'
        }

        failure {
            echo 'auth-service CI pipeline FAILED.'
        }

        always {
            sh '''
                if [ -n "${IMAGE_URI:-}" ]; then
                    docker image rm "${IMAGE_URI}" || true
                fi
            '''
        }
    }
}
