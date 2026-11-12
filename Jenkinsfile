
pipeline {
    agent any

    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        PATH = "/usr/local/bin:/usr/bin:/bin"
    }

    stages {

        stage('Check Kubernetes') {
            steps {
                echo 'Checking Kubernetes cluster...'
                sh 'kubectl get nodes'
            }
        }

        stage('Check Existing Deployments') {
            steps {
                echo 'Checking Blue and Green deployments...'
                sh 'kubectl get deployments'
                sh 'kubectl get pods'
                sh 'kubectl get services'
            }
        }

        stage('Build Blue and Green Images') {
            steps {
                echo 'Building Blue Docker image...'
                sh 'docker build -t myapp:blue app/blue'

                echo 'Building Green Docker image...'
                sh 'docker build -t myapp:green app/green'
            }
        }

        stage('Import Images into K3s') {
            steps {
                echo 'Importing Docker images into K3s containerd...'

                sh 'docker save myapp:blue | sudo -n /usr/local/bin/k3s ctr images import -'

                sh 'docker save myapp:green | sudo -n /usr/local/bin/k3s ctr images import -'
            }
        }

        stage('Deploy Green') {
            steps {
                echo 'Deploying Green environment...'

                sh 'kubectl apply -f k8s/deployment-green.yaml'

                sh 'kubectl rollout status deployment/green-deployment --timeout=120s'
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Green environment is ready. Switch production traffic to Green?',
                      ok: 'Switch to Green'
            }
        }

        stage('Switch Traffic to Green') {
            steps {
                echo 'Switching production traffic to Green...'

                sh """
                    kubectl patch service myapp-service \
                    -p '{"spec":{"selector":{"app":"myapp","color":"green"}}}'
                """
            }
        }

        stage('Verify Green') {
            steps {
                echo 'Verifying Green deployment...'

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
            echo 'Pipeline failed. Check Kubernetes deployments and service.'
        }

        always {
            echo 'VLE-8 pipeline execution finished.'
        }
    }
}
