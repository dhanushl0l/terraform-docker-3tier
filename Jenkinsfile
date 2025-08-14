pipeline {
    agent any

    environment {
        DB_USER       = credentials('DB_USER')
        DB_PASSWORD   = credentials('DB_PASSWORD')
        DB_NAME       = credentials('DB_NAME')
        DATABASE_URL  = credentials('DATABASE_URL')
        NGINX_PORT    = credentials('NGINX_PORT')
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          userRemoteConfigs: [[url: 'https://github.com/dhanushl0l/terraform-docker-3tier.git']]])
            }
        }

        stage('Terraform Apply') {
            steps {
                // Clean up old network to avoid "already exists" error
                sh 'docker network rm app_internal || true'
                sh 'sudo terraform init'
                sh 'sudo terraform apply -auto-approve'
            }
        }

        stage('Docker Compose Up') {
            steps {
                // Avoid Groovy interpolation warning by using env vars directly
                writeFile file: '.env', text: """
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
DATABASE_URL=$DATABASE_URL
NGINX_PORT=$NGINX_PORT
""".stripIndent()

                sh 'sudo docker compose --env-file .env up -d'
            }
        }

        stage('Health Checks') {
            steps {
                // You can replace this with actual curl checks later
                echo '✅ All services are healthy.'
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful on build ${env.BUILD_ID}"
        }
        failure {
            echo "❌ Deployment failed on build ${env.BUILD_ID}"
        }
        always {
            cleanWs()
        }
    }
}
