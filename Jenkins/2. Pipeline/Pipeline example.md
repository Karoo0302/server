# Pipeline example
- - -

파이프라인은 2가지 문법으로 작성이 가능하다
1. Declarative
2. Scripted

여기 예제는 Declarative 로 진행

### Pipeline example

	node{
		DATE = sh (script: 'date', returnStdout: true)
		USER = $BUILD_USER_ID
		# build user vars 플러그인을 통해 빌드유저 확인가능
	}
	pipeline{
		agent {
			kubernetes {
			yaml '''
			apiVersion: v1
			kind: Pod
			metadata:
				labels:
					app: jenkins
			spec:
				containers:
				- name: nodejs
				  image: node:16.14.2
				  command:
				  - cat
				  tty: true
				- name: aws-cli
				  image: custom/aws-cli 
				  # 커스텀 이미지를 사용하여 aws 명령어를 사용가능하게함 docker 와 aws-cli 명령어를 사용할 수 있는 이미지
				  command:
				  - cat
				  tty: true
				  volumeMounts:
				  - name: docker
					mountPath: /var/run/docker.sock
				volumes:
				- name: docker
				  hostPath:
					path: /var/run/docker.sock
				  '''
			}
		}
		environment{
			ProjectName = "test"
			REGION = 'ap-northeast-2'
			ECR_PATH = '0000000000.dkr.ecr.ap-northeast-2.amazonaws.com/test/test-v0.1'
			TOKEN = 'blank' // telegram bot token
			ID = '-1~~' // telegram bot build room
			gitCommit = ""
			ImageTag = ""
			DATE = "${DATE}"
			USER = "${USER}"
		}
		
		stages{
			stage('Checkout'){
				steps{
					git branch: 'master', url: '[git hub link]', credentialsId : 'test-auth'
					script{
						gitCommit = sh (
							script: 'git rev-parse HEAD',
							returnStdout: true
							).trim().take(8)
						ImageTag = "${BUILD_NUMBER}-${gitCommit}"
					}
				}
			}
			stage('Npm install'){
				steps{
					container('nodejs'){
						sh "npm install"
					}
				}
			}
			stage('Npm build'){
				steps{
					container('nodejs'){
						sh "CI= npm run build"
					}
				}
			}
			stage('ECR Set'){
				steps{
					container('aws-cli'){
						sh "aws configure set aws_access_key_id [blank]"
						sh "aws configure set aws_secret_access_key [blank]"
						sh "aws configure set region ap-northeast-2"
						sh "aws configure set output json"
						sh "aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin [ECR path]"
					}
				}
			}
			stage('ECR Build'){
				steps{
					container('aws-cli'){
						sh '''
	cat <<EOF >dockerfile
	FROM node:16.13.1
	RUN apt-get update
	WORKDIR /test\nCOPY ./ ./
	ENTRYPOINT npm run start
	EXPOSE 4000
					'''
						sh "docker build -t ${ECR_PATH}:${ImageTag} ./"
					}
				}
			}
			stage('ECR Push'){
				steps{
					container('aws-cli'){
						sh "docker push ${ECR_PATH}:${ImageTag}"
						sh "docker tag ${ECR_PATH}:${ImageTag} ${ECR_PATH}"
						sh "docker push ${ECR_PATH}"
					}
				}
			}
			stage('Distribute'){
				steps{
					echo "kubectl set image deployment/${ProjectName} ${ProjectName}-c=${ECR_PATH}:${ImageTag} -n test"
				}
			}
		}
		
		post{
			success {
				container('nodejs'){
					sh '''
	curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${ID} -d parse_mode="HTML" -d text="
	Date : ${DATE}
	Project Name : ${JOB_NAME}
	Build Status : SUCCESS ☀️
	URL : http://10.10.10.10:8080/job/${ProjectName}
	Build Number : ${BUILD_NUMBER}
	Build By : ${USER}
	"
	'''
				}
			}
			failure {
				container('nodejs'){
					sh '''
	curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${ID} -d parse_mode="HTML" -d text="
	Date : ${DATE}
	Project Name : ${JOB_NAME}
	Build Status : FAILURE 🌧️
	Error Log : http://10.10.10.10:8080/job/${ProjectName}/${BUILD_NUMBER}/console
	Build Number : ${BUILD_NUMBER}
	Build By : ${USER}
	"
	'''
				}
			}
			aborted {
				container('nodejs'){
					sh '''
	curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${ID} -d parse_mode="HTML" -d text="
	Date : ${DATE}
	Project Name : ${JOB_NAME}
	Build Status : ABORTED 🌩️
	URL : http://10.10.10.10:8080/job/${ProjectName}
	Build Number : ${BUILD_NUMBER}
	Aborted By : ${USER}
	"
	'''
				}
			}
		}
	}