# Kubernetes 1.25.3 Version Installed

## 구동환경
OS: Debian11
Container-runtime: containerd
   설치방법: [Containerd 설치](https://github.com/Karoo0302/server/blob/main/kubernetes/Package_Install/Containerd_installed.md)
K8S_ver: 1.25.3

	cat <<EOF | tee /etc/modules-load.d/k8s.conf
	overlay
	br_netfilter
	EOF

	modprobe overlay
	modprobe br_netfilter

	cat <<EOF | tee /etc/sysctl.d/k8s.conf
	net.bridge.bridge-nf-call-iptables  = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	net.ipv4.ip_forward                 = 1
	EOF

	sysctl --system

	echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" |  tee /etc/apt/sources.list.d/kubernetes.list

	apt-get update

	apt-get install -y kubelet=1.25.3-00 kubeadm=1.25.3-00 kubectl=1.25.3-00
