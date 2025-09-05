pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "676206916950"
        AWS_REGION = "us-east-1"          // change if needed
        ECR_REPO_NAME = "ci-cd-jenkins-app"
        IMAGE_TAG = "latest"
        SONARQUBE = "sonarqube"           // Jenkins SonarQube server name (configure in Manage Jenkins)
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/PriyankaPatil-97/CI-CD-jenkins-app.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh '''
                  trivy fs --exit-code 0 --severity HIGH,CRITICAL .
                '''
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh """
                      docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh """
                  trivy image --exit-code 0 --severity HIGH,CRITICAL ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('ECR Login & Push') {
            steps {
                script {
                    sh """
                      aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                      aws ecr describe-repositories --repository-names ${ECR_REPO_NAME} --region ${AWS_REGION} || aws ecr create-repository --repository-name ${ECR_REPO_NAME} --region ${AWS_REGION}
                      docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy Local Docker') {
            steps {
                script {
                    sh """
                      docker rm -f myapp || true
                      docker run -d --name myapp -p 9091:8080 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }
}
