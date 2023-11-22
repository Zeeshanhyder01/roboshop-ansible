pipeline{
    agent { label 'MY-WORKSTATION' }


    environment {
        CREDENTIALS=credentials('SSH CONNECTION')

    }

    parameters{
        string(name: 'COMPONENT', defaultValue: '', description: 'WhICH COMPONENT TO RUN THE PIPELINE?')
    }

    stages{
        stage{
            steps{
                sh'''HOST=$(echo "${COMPONENT}" | tr '[:lower:]' '[:upper:]')'
                 'ansible-playbook -i inv.roboshop roboshop.yml -e HOST=${HOST} -e ROLE=${COMPONENT} -e ansible_user=${ANSIBLE_USER} -e ansible_password=${ANSIBLE_PASSWORD}' 
                 '''
            }
        }
    }
}