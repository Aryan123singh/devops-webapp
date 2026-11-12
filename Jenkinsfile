pipeline {
    agent any

    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        PATH = "/usr/local/bin:/usr/bin:/bin"
    }

    stages {
        stage('Check Kubernetes') {
            steps {
                sh 'kubectl get nodes'
            }
        }

        stage('Check Deployments') {
            steps {
                sh 'kubectl get deployments'
                sh 'kubectl get pods'
            }
        }

        stage('Deploy Green') {
            steps {
                sh 'kubectl apply -f /home/ubuntu/VLE8/k8s/deployment-green.yaml'
                sh 'kubectl rollout status deployment/green-deployment --timeout=120s'
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Green is ready. Switch production traffic to Green?',
                      ok: 'Switch to Green'
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                sh """
                    kubectl patch service myapp-service \
                    -p '{"spec":{"selector":{"app":"myapp","color":"green"}}}'
                """
            }
        }

        stage('Verify Green') {
            steps {
                sh 'kubectl get endpoints myapp-service'
                sh 'curl -fsS http://localhost:30080'
            }
        }
    }

    post {
        success {
            echo 'Blue-Green deployment completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the deployment and service.'
        }
    }
}
