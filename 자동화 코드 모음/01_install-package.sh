apt update

apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2 nfs-common

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

apt-get update

apt-get install -y containerd.io=1.6.15-1

containerd config default > /etc/containerd/config.toml

cd /etc/containerd

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' config.toml

cd /root

systemctl restart containerd


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

#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
mv kubernetes-archive-keyring.gpg /usr/share/keyrings/

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" |  tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

apt-get install -y kubelet=1.25.3-00 kubeadm=1.25.3-00 kubectl=1.25.3-00

echo -e "\nSetting K8S Cluster Connection IP\n"
echo "vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
echo "--node-ip [kubernetes connection IP]"
