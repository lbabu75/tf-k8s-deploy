pipeline {
    agent any

    environment {
        GCP_CREDENTIALS = credentials('your-gcp-service-account-key-credential-id')
        TERRAFORM_WORKSPACE = '/path/to/terraform/workspace'
        KUBE_CONFIG_PATH = '/path/to/terraform/workspace/kubeconfig.yaml'
        DOCKER_REGISTRY_CREDENTIAL = credentials('your-docker-registry-credential-id')
        HELM_RELEASE_NAME = 'my-mediawiki'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform - Create Kubernetes Cluster') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'your-gcp-service-account-key-credential-id', variable: 'GCP_CREDENTIALS_PATH')]) {
                        sh "cd ${TERRAFORM_WORKSPACE}"
                        sh "terraform init"
                        sh "terraform apply -auto-approve -var-file=terraform.tfvars"
                        sh "gcloud container clusters get-credentials my-k8s-cluster --region us-central1 --project your-gcp-project-id"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Your Docker build steps here
                    sh 'docker build -t your-docker-registry/your-mediawiki-app:${BUILD_NUMBER} .'
                    sh 'docker push your-docker-registry/your-mediawiki-app:${BUILD_NUMBER}'
                }
            }
        }

        stage('Deploy to Kubernetes - Rolling Update') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'your-docker-registry-credential-id', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        withCredentials([file(credentialsId: 'your-kube-config-credential-id', variable: 'KUBE_CONFIG_PATH')]) {
                            sh "kubectl create secret docker-registry docker-registry-secret --docker-server=your-docker-registry --docker-username=${DOCKER_USERNAME} --docker-password=${DOCKER_PASSWORD} --docker-email=your-email@example.com"
                            sh "helm upgrade --install ${HELM_RELEASE_NAME} bitnami/mediawiki -f values.yaml --set image.repository=your-docker-registry/your-mediawiki-app,image.tag=${BUILD_NUMBER} --set mediawiki.deploymentStrategy=RollingUpdate"
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes - Blue-Green Update') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'your-docker-registry-credential-id', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        withCredentials([file(credentialsId: 'your-kube-config-credential-id', variable: 'KUBE_CONFIG_PATH')]) {
                            sh "helm install --name ${HELM_RELEASE_NAME}-blue bitnami/mediawiki -f bluegreen.yaml --set image.repository=your-docker-registry/your-mediawiki-app,image.tag=${BUILD_NUMBER}"
                            sh "helm upgrade --install ${HELM_RELEASE_NAME}-green bitnami/mediawiki -f values.yaml --set image.repository=your-docker-registry/your-mediawiki-app,image.tag=${BUILD_NUMBER} --set mediawiki.deploymentStrategy=BlueGreen"
                        }
                    }
                }
            }
        }
    }
}
