pipeline {
  agent any

  environment {
    REGISTRY = credentials('container-registry-url')
    REGISTRY_CREDENTIALS = 'container-registry-credentials'
    IMAGE_NAMESPACE = 'devops-assignment'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout Source') {
      steps {
        checkout scm
      }
    }

    stage('Lint') {
      parallel {
        stage('Frontend Lint') {
          steps {
            sh 'cd frontend && npm run lint'
          }
        }
        stage('Backend Lint') {
          steps {
            sh 'cd backend && python -m pip install -r requirements-dev.txt -r requirements.txt && ruff check app tests'
          }
        }
      }
    }

    stage('Unit Tests') {
      parallel {
        stage('Frontend Tests') {
          steps {
            sh 'cd frontend && npm test'
          }
        }
        stage('Backend Tests') {
          steps {
            sh 'cd backend && python -m pip install -r requirements-dev.txt -r requirements.txt && pytest'
          }
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh '''
          docker build -t ${REGISTRY}/${IMAGE_NAMESPACE}/api:${IMAGE_TAG} backend
          docker build -t ${REGISTRY}/${IMAGE_NAMESPACE}/frontend:${IMAGE_TAG} frontend
        '''
      }
    }

    stage('Security Scan') {
      steps {
        sh '''
          trivy image --severity CRITICAL --exit-code 1 ${REGISTRY}/${IMAGE_NAMESPACE}/api:${IMAGE_TAG}
          trivy image --severity CRITICAL --exit-code 1 ${REGISTRY}/${IMAGE_NAMESPACE}/frontend:${IMAGE_TAG}
        '''
      }
    }

    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.REGISTRY_CREDENTIALS, usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_PASSWORD')]) {
          sh '''
            echo "${REGISTRY_PASSWORD}" | docker login "${REGISTRY}" -u "${REGISTRY_USER}" --password-stdin
            docker push ${REGISTRY}/${IMAGE_NAMESPACE}/api:${IMAGE_TAG}
            docker push ${REGISTRY}/${IMAGE_NAMESPACE}/frontend:${IMAGE_TAG}
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          kubectl set image deployment/api api=${REGISTRY}/${IMAGE_NAMESPACE}/api:${IMAGE_TAG} -n devops-assignment
          kubectl set image deployment/frontend frontend=${REGISTRY}/${IMAGE_NAMESPACE}/frontend:${IMAGE_TAG} -n devops-assignment
        '''
      }
    }

    stage('Post-Deployment Validation') {
      steps {
        sh '''
          kubectl rollout status deployment/api -n devops-assignment --timeout=180s
          kubectl rollout status deployment/frontend -n devops-assignment --timeout=180s
          kubectl get pods -n devops-assignment
        '''
      }
    }
  }

  post {
    failure {
      sh '''
        kubectl rollout undo deployment/api -n devops-assignment || true
        kubectl rollout undo deployment/frontend -n devops-assignment || true
      '''
    }
  }
}
