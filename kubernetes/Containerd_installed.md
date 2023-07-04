# Containerd 1.6.15 버전 설치하기
----------

쿠버네티스 1.23.~ 버전이후부터 Containerd 1.6버전 이하의 버전은 Container runtime으로 인식을 못한다.
<br>
그러므로 1.6 버전이상의 containerd를 설치해야한다.


	apt update  

	apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2 nfs-common  

	curl -fsSL [https://download.docker.com/linux/debian/gpg](https://download.docker.com/linux/debian/gpg) | apt-key add -  

	add-apt-repository "deb \[arch=amd64\] [https://download.docker.com/linux/debian](https://download.docker.com/linux/debian) $(lsb\_release -cs) stable"  

	apt-get update  

	apt-get install -y containerd.io=1.6.15-1  

	containerd config default > /etc/containerd/config.toml  

	cd /etc/containerd  

	sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' config.toml  

	cd /root  

	systemctl restart containerd
