pipeline{
  agent any
   stages{
    stage('Build Tools') {
      steps {
        sh '''#!/bin/bash
        source testenv/bin/activate
        node --max-old-space-size=100 /usr/bin/npm install --save-dev cypress@7.6.0
        /usr/bin/npx cypress verify
        '''
      }
    }
    stage('Build App') {
      steps {
        sh '''#!/bin/bash
        python3 -m venv testenv
        source testenv/bin/activate
        pip install pip --upgrade
        pip install -r requirements.txt
        export FLASK_APP=application
        flask run &
        '''
      }
    }
    stage('Pytest') {
      steps {
        sh '''#!/bin/bash
          source testenv/bin/activate
          py.test --verbose --junit-xml test-reports/pytest-results.xml
          '''
      }
      post{
        always {
          junit 'test-reports/pytest-results.xml'
        }
      }
    }
    stage('Pylint') {
      steps {
        sh '''#!/bin/bash
          source testenv/bin/activate
          pylint --output-format=text,pylint_junit.JUnitReporter:test-reports/pylint-results.xml application.py
          '''
      }
      post{
        always {
          junit 'test-reports/pylint-results.xml'
        }
      }
    }
    stage('Terraform Init') {
      steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'aws_access_key_id'), 
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'aws_secret_access_key')]) {
                          dir('intTerraform') {
                             sh 'terraform init' 
                          }
        }
      }
    }
    stage('Terraform Plan') {
      steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'aws_access_key_id'), 
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'aws_secret_access_key')]) {
                          dir('intTerraform') {
                            sh 'terraform plan -out plan.tfplan -var="aws_access_key_id=$aws_access_key_id" -var="aws_secret_access_key=$aws_secret_access_key"' 
                          }
        }
      }
    }
    stage('Terraform Apply') {
      steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'aws_access_key_id'), 
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'aws_secret_access_key')]) {
                          dir('intTerraform') {
                            sh 'terraform apply plan.tfplan' 
                          }
        }
      }
    }
    stage('Cypress E2E') {
      steps {
        sh '''#!/bin/bash
          source testenv/bin/activate
          NO_COLOR=1 /usr/bin/npx cypress run --config video=false --spec cypress/integration/test.spec.js
          '''
      }
      post{
        always {
          junit 'test-reports/cypress-results.xml'
        }
      }
    }
    stage('Terraform Destroy') {
      steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'aws_access_key_id'),
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'aws_secret_access_key')]) {
                          dir('intTerraform') {
                            sh 'terraform destroy -auto-approve -var="aws_access_key_id=$aws_access_key_id" -var="aws_secret_access_key=$aws_secret_access_key"'
                          }
        }
      }
    }
  }
}