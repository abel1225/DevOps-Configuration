```shell
pipeline {
agent any

	environment {
		git_addr=""
		target_dir="/opt/application"
		target_ssh="root@serverid"
		api_url=""
		sonar_url=""
		backup_dir="/opt/app/backup"
	}

	stages {
		stage('获取代码') {
			steps {
				echo "start fetch code from git:${git_addr}"
				deleteDir()
				git "${git_addr}"
			}
		}

		stage('代码静态检查') {
            when {
                environment name:'test', value:'是'
            }
			steps {
				echo "start code check"
				sh "mvn clean compile sonar:sonar -Dsonar.host.url=http://${sonar_url}"
			}
		}
		
		stage('单元测试') {
            when {
                environment name:'test', value:'是'
            }
			steps {
				echo "start test"
				sh "mvn test"
				junit '**/target/surefire-reports/TEST-*.xml'
			}
		}

		stage('打包') {
			steps {
				echo "start package"
				sh "sed -i 's/127.0.0.1:9900/${api_url}/g' zlt-web/back-web/src/main/resources/static/module/apiUrl.js"
				sh "mvn package -Dmaven.test.skip=true"
			}
		}

		stage('部署') {
			steps {
				echo "start deploy"

				sh '''
                    if [ ! -d "${backup_dir}/${project_version}" ];then
					    mkdir -p ${backup_dir}/${project_version}
					fi
                '''

				script {
                    def apps = "${service_names}".split(",")
                    for (int i = 0; i < apps.size(); ++i) {
                    	if ("${apps[i]}" == 'zlt-uaa') {
				            service_path = ''
				        } else {
				            service_path = '*/'
				        }
				        sh "rm -f ${backup_dir}/${project_version}/${apps[i]}.jar"
                        sh "cp "+service_path+"${apps[i]}/target/*.jar ${backup_dir}/${project_version}/"

				        sh "ssh ${target_ssh} rm -f ${target_dir}/${apps[i]}.jar"
                        sh "scp "+service_path+"${apps[i]}/target/*.jar ${target_ssh}:${target_dir}"
                    }
                }
			}
		}
		
		stage('重启') {
			steps {
				echo "start restart"
				script {
                    def apps = "${service_names}".split(",")
                    for (int i = 0; i < apps.size(); ++i) {
                        sh "ssh ${target_ssh} 'cd ${target_dir};sh shutdown.sh ${apps[i]}'"
                        if ("${apps[i]}" == 'sc-admin') {
				            sleep 60
				        } else {
				            sleep 30
				        }
                        sh "ssh ${target_ssh} 'cd ${target_dir};sh start.sh ${apps[i]}'"
                    }
                }
			}
		}
	}
	
	post {
        always {
            echo '构建结束...'
        }
        success {
            echo '恭喜您，构建成功！！！'
        }
        failure {
            echo '抱歉，构建失败！！！'
        }
        unstable {
            echo '该任务已经被标记为不稳定任务....'
        }
        changed {
            echo ''
        }
    }
}
```