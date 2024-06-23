// @Library('jenkins-pipeline-util') _

pipeline {
    agent any
    parameters {
        choice(
            name: 'ENVIRONMENT',
            description: 'Select Environment for Deployment',
            choices:['dev','stg','prd']
        )
        string (
            name: 'VERSION',
            defaultValue: '',
            description: 'Provide FRONTEND VERSION to Deploy/Upgrade/Remove such as: v0.5-69-g19bb5e0',
            trim: true
        )

        choice(
            name: 'REGION',
            description: 'Select Environment for Deployment',
            choices:['east-us','west-us','all']
        )
        choice(name: 'REQUEST', description: 'All roles that make use of this artifact will be updated.', choices: [
            'Please select',
            'deploy-new-stack',
            'upgrade-api-stack',
            'upgrade-frontend-stack',
            'rollback-api-stack',
            'rollback-frontend-stack',
            'remove-existing-stack',
            'list-artifacts-files'
            ])

        choice(
            name: 'HOSTS',
            description: 'Select Environment for Deployment',
            choices:['kafka01','kafka02', 'all']
        )

    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/tajuddin-sonata/git-repo.git'
            }  
        }
        stage ('Deploy artifact') {
            steps {
                script {
                    currentBuild.displayName = "deploy-${ENVIRONMENT}-${STACK}-${REQUEST}-${BUILD_ID}"
                }
                withEnv([
                    "ENVIRONMENT=${ENVIRONMENT}",
                    "API_VERSION=${API_VERSION}",
                    "ARTIFACT_VERSION=${VERSION}",
                    "BUILD_ID=${BUILD_ID}",
                    "REGION=${REGION}",
                    "HOSTS=${HOSTS}"
                ]) {
                    sh 'bash deploy_releases.sh'
                }
            }
        }
    }
    post { 
        always {
            emailext (attachLog:true, body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to:'taj.070796@gmail.com')
            cleanWs()
        }
    }
}
