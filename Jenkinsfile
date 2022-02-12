pipeline{
    agent any
    stages{
        stage('git checkout'){
            git 'https://github.com/godithipradeep/test.git'
        }
        stage('run nginx playbook'){
            ansiblePlaybook credentialsId: 'ansible', disableHostKeyChecking: true, installation: 'ansible', inventory: 'inventory', playbook: 'nginx.yml'
        }
    }
}