# ETCD
- - -

### ETCD란

etcd란 분산시스템 또는 클러스터 환경에서 지속적인 실행을 위해 필요한 중요한 정보를 보관하고 관리하는 분산 오픈소스 키-값 저장소다.

이 문서에서는 etcd에 대한 동작원리는 설명하지 않는다.
etcd 의 동작원리를 간단하게 설명한 블로그 주소를 첨부하도록 하겠다.
- https://tech.kakao.com/2021/12/20/kubernetes-etcd/

### ETCD 멤버 체크

etcd 멤버 체크

	ETCDCTL_API=3 etcdctl -w table member list \
	--endpoints=https://127.0.0.1:2379 \
	--cacert /etc/kubernetes/pki/etcd/ca.crt \
	--cert /etc/kubernetes/pki/etcd/server.crt \
	--key /etc/kubernetes/pki/etcd/server.key
	
etcd 클러스터 체크
	
	ETCDCTL_API=3 etcdctl endpoint status --cluster -w table \
	--endpoints=https://127.0.0.1:2379 \
	--cacert /etc/kubernetes/pki/etcd/ca.crt \
	--cert /etc/kubernetes/pki/etcd/server.crt \
	--key /etc/kubernetes/pki/etcd/server.key


위 명령어를 통해 etcd 멤버들의 상태를 확인 할 수 있으며 장애가 있는 멤버 또한 검출 할 수 있다.
또한 Version과 DB size 항목을 통해 분산시스템이 안전하게 저장되고 있는지 체크할 수 있다.

### etcd 백업 및 복구

멀티마스터(3개)로 구성된 클러스터를 복구하는 방법에 대해 설명하겠다.

#### 주의사항
- - -
etcd를 백업하고 복구 할 경우 etcd는 노드정보,클러스터 정보,Pod 정보등 모든 정보를 복구한다.
그러므로 기존 클러스터와 환경을 동일하게 구성하여 클러스터를 복구하여야 안전하게 복구가 가능하다.

백업 파일 만들기

	ETCDCTL_API=3 etcdctl snapshot save backup.db \
	--endpoints=https://127.0.0.1:2379 \
	--cacert=/etc/kubernetes/pki/etcd/ca.crt \
	--cert=/etc/kubernetes/pki/etcd/server.crt \
	--key=/etc/kubernetes/pki/etcd/server.key

위의 명령어를 입력하면 backup.db 파일이 생성된다. 위 파일을 통해 etcd 복구가 가능하다.

	IP정보
	m1 : 192.168.87.130:2380
	m2 : 192.168.87.131:2380
	m3 : 192.168.87.132:2380

위 백업 파일을 3개의 마스터노드에 전부 저장한다. 이후 아래의 명령어를 실행해준다.

	ETCDCTL_API=3 etcdctl snapshot restore backup.db --name m1 \
	--cacert=/etc/kubernetes/pki/etcd/ca.crt \
	--cert=/etc/kubernetes/pki/etcd/server.crt \
	--key=/etc/kubernetes/pki/etcd/server.key \
	--initial-cluster m1=https://192.168.87.130:2380,m2=https://192.168.87.131:2380,m3=https://192.168.87.132:2380 \
	--initial-cluster-token etcd-cluster-1 \
	--initial-advertise-peer-urls https://192.168.87.130:2380

	ETCDCTL_API=3 etcdctl snapshot restore backup.db --name m2 \
	--cacert=/etc/kubernetes/pki/etcd/ca.crt \
	--cert=/etc/kubernetes/pki/etcd/server.crt \
	--key=/etc/kubernetes/pki/etcd/server.key \
	--initial-cluster m1=https://192.168.87.130:2380,m2=https://192.168.87.131:2380,m3=https://192.168.87.132:2380 \
	--initial-cluster-token etcd-cluster-1 \
	--initial-advertise-peer-urls https://192.168.87.131:2380

	ETCDCTL_API=3 etcdctl snapshot restore backup.db --name m3 \
	--cacert=/etc/kubernetes/pki/etcd/ca.crt \
	--cert=/etc/kubernetes/pki/etcd/server.crt \
	--key=/etc/kubernetes/pki/etcd/server.key \
	--initial-cluster m1=https://192.168.87.130:2380,m2=https://192.168.87.131:2380,m3=https://192.168.87.132:2380 \
	--initial-cluster-token etcd-cluster-1 \
	--initial-advertise-peer-urls https://192.168.87.132:2380

이후 m1.etcd ~ m3.etcd의 파일이 각 노드에 생성된다.

아래 명령어를 통해 쿠버네티스 클러스터를 복구한다.

	[모든 마스터 노드 진행]
	- etcd / kube-api-server / controlmanager 등 멈춤
	mv /etc/kubernetes/manifests/*.yaml /root/etcd-restore

	- 백업파일 복사
	mv /var/lib/etcd/member /var/lib/etcd/member.bak
	cp -r m1.etcd/member /var/lib/etcd/

	mv /var/lib/etcd/member /var/lib/etcd/member.bak
	cp -r m2.etcd/member /var/lib/etcd/

	mv /var/lib/etcd/member /var/lib/etcd/member.bak
	cp -r m3.etcd/member /var/lib/etcd/

	- etcd / kube-api-server / controlmanager 등 재시작
	mv /root/etcd-restore/*.yaml /etc/kubernetes/manifests/

