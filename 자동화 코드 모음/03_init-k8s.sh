echo "Control-plane-endpoint IP:port : "
read LBIP
echo "Master 1st IP : "
read master

echo "
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: \"$master\"
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: \"$LBIP\"
networking:
  podSubnet: \"10.244.0.0/16\"" >> kubeadm-config.yaml

kubeadm init --upload-certs --config kubeadm-config.yaml

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

bash 3-1_join-print.sh
