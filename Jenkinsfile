pipeline {
    agent any

    parameters {
        string(name: 'DOCKERHUB_USERNAME', defaultValue: '', description: 'Docker Hub Username')
        string(name: 'IMAGE_NAME', defaultValue: '01-maven-web-app', description: 'Docker Image Name')
        string(name: 'IMAGE_TAG', defaultValue: 'v1', description: 'Docker Image Tag')
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Chenikala9/maven-web-app.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${params.IMAGE_NAME}:${params.IMAGE_TAG} ."
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Docker Tag') {
            steps {
                sh """
                docker tag ${params.IMAGE_NAME}:${params.IMAGE_TAG} \
                ${params.DOCKERHUB_USERNAME}/${params.IMAGE_NAME}:${params.IMAGE_TAG}
                """
            }
        }

        stage('Docker Push') {
            steps {
                sh """
                docker push ${params.DOCKERHUB_USERNAME}/${params.IMAGE_NAME}:${params.IMAGE_TAG}
                """
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
    }
}
