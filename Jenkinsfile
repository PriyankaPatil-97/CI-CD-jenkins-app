pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "676206916950"
        AWS_REGION     = "ap-south-1"
        ECR_REPO       = "my-sample-app"
        IMAGE_NAME     = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
        IMAGE_TAG      = "${BUILD_NUMBER}"
    }

    tools { maven "Maven" }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                // Compile and package the app
                sh 'mvn clean package'

                // Run unit tests and publish results
                junit 'target/surefire-reports/*.xml'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('SonarQube') {
                        sh "mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN"
                    }
                }
            }
        }

        stage('Trivy Scan (Code)') {
            steps {
                sh 'trivy fs --exit-code 0 --severity HIGH,CRITICAL . || true'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Trivy Scan (Image)') {
            steps {
                sh 'trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG} || true'
            }
        }

        stage('ECR Login & Push') {
            steps {
                sh '''
                  aws ecr get-login-password --region ${AWS_REGION} | \
                  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                  
                  docker push ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy (Local Docker)') {
            steps {
                sh '''
                  docker stop my-sample-app || true
                  docker rm my-sample-app || true
                  docker run -d -p 9090:9090 --name my-sample-app ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                  # Force ECS service to pull the new image and redeploy
                  aws ecs update-service \
                    --cluster my-sample-cluster \
                    --service my-sample-service \
                    --force-new-deployment \
                    --region ${AWS_REGION}
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline finished"
        }
        failure {
            echo "Pipeline failed! Check logs."
        }
    }
}
