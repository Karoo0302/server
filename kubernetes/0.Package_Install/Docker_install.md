# Docker 설치하기
- - -
도커는 Kubernetes의 Container runtime으로 사용할 수 있으며, Jenkins를 이용할 때도 사용한다.

### 명령어
	apt update
	apt install apt-transport-https ca-certificates curl software-properties-common gnupg2
	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - 
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
	apt update
	apt install docker-ce
   
Cgroup 변경하기

	cat <<EOF | tee /etc/docker/daemon.json
	{
	"exec-opts": ["native.cgroupdriver=systemd"],
	"log-driver": "json-file",
	"log-opts": {
	"max-size": "100m"
	},
	"storage-driver": "overlay2"
	}
	EOF