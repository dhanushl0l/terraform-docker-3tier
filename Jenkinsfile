pipeline {
    agent any

    triggers {
        // i recomment to use webhook it is optimal 
        pollSCM('H/5 * * * *') 
    }

    stages {
        stage('Checkout') {
            when {
                branch 'main'
            }
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/dhanushl0l/terraform-docker-3tier.git'
                    ]]
                ])
            }
        }

        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                dir('terraform') {
                    sh 'sudo terraform apply -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo "✅ Terraform applied successfully on ${env.BUILD_ID}"
        }
        failure {
            echo "❌ Terraform apply failed on ${env.BUILD_ID}"
        }
        always {
            cleanWs()
        }
    }
}
