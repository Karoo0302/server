systemctl stop kubelet
systemctl stop containerd

ip link delete cni0
ip link delete flannel.1

rm -rf /var/lib/cni/
rm -rf /run/flannel
rm -rf /etc/cni
rm -rf ~/.kube
