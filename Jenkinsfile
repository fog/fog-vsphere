pipeline {
  agent any
  stages {
    stage('Start Ansible Job') {
      steps {
        ansibleTower(jobTemplate: '8', towerServer: 'https://tower.satellite.lab.eng.rdu2.redhat.com', jobType: 'run', inventory: 'Upstream-Fog', importTowerLogs: true, verbose: true, credential: 'Fog-SSH', throwExceptionWhenFail: true, importWorkflowChildLogs: true, templateType: 'job')
      }
    }
  }
}