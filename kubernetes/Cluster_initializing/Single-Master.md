# Single Master Cluster initializing
쿠버네티스는 마스터노드와 워커노드로 이루어져있어 클러스터로 묶어 사용한다.<br>
단일마스터 노드는 별도의 추가 노드필요없이 마스터노드 1대와 워커노드 여러대로 구성이 가능하다<br>

### 마스터노드 구축하기
	kubeadm init --apiserver-advertise-address [master ip] --pod-network-cidr=10.244.0.0/16

마스터노드의 구축이 끝나면 하단에 Join 명령어가 생성된다. 해당 명령어를 복사하여 워커노드에게 실행시킨디ㅏ.

### Join 명령어를 잃어버렸을경우 아래의 명령어로 join 명령어를 생성 할 수 있다.

	kubeadm token create --print-join-command

### Master Node 권한 및 자동완성

	mkdir -p $HOME/.kube
	cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	chown $(id -u):$(id -g) $HOME/.kube/config
	export KUBECONFIG=/etc/kubernetes/admin.conf
	
	source <(kubectl completion bash) 
	echo "source <(kubectl completion bash)" >> ~/.bashrc
