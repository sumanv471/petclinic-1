pipeline {
	agent { label 'master' }

	tools {
		maven 'M3.6.3'
	}
	
	environment {
		def tomcatDevIp = '40.87.89.207'
		def tomcatHome = '/home/nexus/tomcat8'
        def tomcatStart = "${tomcatHome}/bin/startup.sh"
        def tomcatStop = "${tomcatHome}/bin/shutdown.sh"
	}

	stages {
		stage('Checkout') {
			steps {
				git url: 'https://github.com/akmaharshi/petclinic.git'
			}
		}

		stage('Maven Build') {
			input {
                message "Should we continue?"
                ok "Yes, Proceed"
                parameters {
                    string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
                }
            }
			steps {
				echo "Hello, ${PERSON}, nice to meet you."
				sh label: '', script: 'mvn clean package'
			}
		}
		stage('Post Build Actions') {
			parallel {
				stage('Archive Artifacts') {
					steps {
						archiveArtifacts artifacts: 'target/*.?ar', followSymlinks: false
					}
				}

				stage('Test Results') {
					steps {
						junit 'target/surefire-reports/*.xml'
					}
				}
				
				stage('Nexus Uploader') {
					steps {
						nexusArtifactUploader artifacts: [[artifactId: 'spring-petclinic', classifier: '', file: 'target/petclinic.war', type: 'war']], credentialsId: 'nexuscred', groupId: 'org.springframework.samples', nexusUrl: '40.87.89.207:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-releases', version: "4.2.${BUILD_NUMBER}"
					}
				}
				
				stage('Deploy') {
					steps {
                                		sh "scp -o StrictHostKeyChecking=no target/petclinic.war nexus@${tomcatDevIp}:/home/nexus/tomcat8/webapps/myweb.war"
                                		sh "ssh nexus@${tomcatDevIp} ${tomcatStop}"
                                		sh "ssh nexus@${tomcatDevIp} ${tomcatStart}"
                            		}
				}
			}
		}
	}

	post {
		success {
			notify('Success')
		}
		failure {
			notify('Failed')
		}
		aborted {
			notify('Aborted')
		}
	}

}

def notify(status){
    emailext (
      to: "sumaanvemuri@gmail.com",
      subject: "${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
      body: """<p>${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
    )
}
