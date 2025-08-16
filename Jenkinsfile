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
                // to avoide unnecessary duplicate
                sh 'docker network rm app_internal || true'
                sh 'sudo terraform init'
                sh 'sudo terraform apply -auto-approve'
            }
        }

        stage('Docker Compose Up') {
            steps {
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
                script {
                    // Helper function for retries
                    def checkInContainer = { container, cmd ->
                        retry(5) {
                            sleep(time: 10, unit: 'SECONDS')
                            sh "sudo docker exec ${container} sh -c '${cmd}'"
                        }
                    }

                    // check if Postgres is accepting connections
                    checkInContainer("postgres-db", "pg_isready -U $DB_USER -d $DB_NAME")

                    // check if backend responds on its port (inside container network)
                    checkInContainer("rust-backend", "curl -fs http://localhost:8081/get")

                    // check if frontend responds on its port
                    checkInContainer("frontend", "curl -fs http://localhost:80/")

                    echo '✅ All containers passed health checks.'
                }
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
