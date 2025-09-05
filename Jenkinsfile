pipeline {
  agent any

  environment {
    AWS_ACCOUNT_ID = "676206916950"
    AWS_REGION     = "ap-south-1"
    ECR_REPO       = "ci-cd-jenkins-app"
    IMAGE_NAME     = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    IMAGE_TAG      = "${BUILD_NUMBER}"
  }

  tools { maven "Maven" }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/PriyankaPatil-97/CI-CD-jenkins-app.git'
      }
    }

    stage('Build (package)') {
      steps {
        sh 'mvn -B -DskipTests clean package'
      }
    }

      stage('Unit Tests') {
      steps {
        sh 'mvn -B test'
        junit '**/target/surefire-reports/*.xml'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
          withSonarQubeEnv('SonarQube') {
            sh 'mvn -B sonar:sonar -Dsonar.login=$SONAR_TOKEN'
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo "Skipping Quality Gate check for now"
      }
    }

    stage('Trivy Scan (Source)') {
      steps {
        sh '''
          trivy fs --exit-code 0 --severity HIGH,CRITICAL .
        '''
      }
    }

    stage('Docker Build') {
      steps {
        sh """
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
        """
      }
    }

    stage('Trivy Scan (Image)') {
      steps {
        sh """
          trivy image --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG}
        """
      }
    }

    stage('ECR Login & Push') {
      steps {
        sh """
          aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
          aws ecr describe-repositories --repository-names ${ECR_REPO} --region ${AWS_REGION} || aws ecr create-repository --repository-name ${ECR_REPO} --region ${AWS_REGION}
          docker push ${IMAGE_NAME}:${IMAGE_TAG}
        """
      }
    }

    stage('Deploy Locally on EC2') {
      steps {
        sh """
          docker rm -f myapp || true
          docker run -d --name myapp -p 9091:8080 ${IMAGE_NAME}:${IMAGE_TAG}
        """
      }
    }

  }
}
