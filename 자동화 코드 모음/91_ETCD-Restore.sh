echo "ETCD snapshot file name: "
read file

echo "HA-Master IP :"
echo "ex) 10.10.10.1 10.10.10.2 10.10.10.3"
read -a ip

echo "2nd Master node Command"
echo "--------------------------------------------------------------------------------------------"
echo -e "ETCDCTL_API=3 etcdctl snapshot restore $file --name m2 \\
--cacert=/etc/kubernetes/pki/etcd/ca.crt \\
--cert=/etc/kubernetes/pki/etcd/server.crt \\
--key=/etc/kubernetes/pki/etcd/server.key \\
--initial-cluster m1=https://${ip[0]}:2380,m2=https://${ip[1]}:2380,m3=https://${ip[2]}:2380 \\
--initial-cluster-token etcd-cluster-1 \\
--initial-advertise-peer-urls https://${ip[1]}:2380"
echo "--------------------------------------------------------------------------------------------"
echo "3rd Master node Command"
echo "--------------------------------------------------------------------------------------------"
echo -e "ETCDCTL_API=3 etcdctl snapshot restore $file --name m3 \\
--cacert=/etc/kubernetes/pki/etcd/ca.crt \\
--cert=/etc/kubernetes/pki/etcd/server.crt \\
--key=/etc/kubernetes/pki/etcd/server.key \\
--initial-cluster m1=https://${ip[0]}:2380,m2=https://${ip[1]}:2380,m3=https://${ip[2]}:2380 \\
--initial-cluster-token etcd-cluster-1 \\
--initial-advertise-peer-urls https://${ip[2]}:2380"
echo "--------------------------------------------------------------------------------------------"
ETCDCTL_API=3 etcdctl snapshot restore $file --name m1 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--initial-cluster m1=https://${ip[0]}:2380,m2=https://${ip[1]}:2380,m3=https://${ip[2]}:2380 \
--initial-cluster-token etcd-cluster-1 \
--initial-advertise-peer-urls https://${ip[0]}:2380

echo "Press Enter..."
read enter

echo "2nd,3rd Master Command"
echo "--------------------------------------------------------------------------------------------"
echo "mkdir /root/etcd-restore"
echo "mv /etc/kubernetes/manifests/*.yaml /root/etcd-restore"
echo "mv /var/lib/etcd/member /var/lib/etcd/member.bak"
echo "cp -r m2.etcd/member /var/lib/etcd/"
echo "mv /root/etcd-restore/*.yaml /etc/kubernetes/manifests/"
echo "--------------------------------------------------------------------------------------------"
echo "mkdir /root/etcd-restore"
echo "mv /etc/kubernetes/manifests/*.yaml /root/etcd-restore"
echo "mv /var/lib/etcd/member /var/lib/etcd/member.bak"
echo "cp -r m3.etcd/member /var/lib/etcd/"
echo "mv /root/etcd-restore/*.yaml /etc/kubernetes/manifests/"
echo "Press Enter..."
read enter

mkdir /root/etcd-restore
mv /etc/kubernetes/manifests/*.yaml /root/etcd-restore
mv /var/lib/etcd/member /var/lib/etcd/member.bak
cp -r m1.etcd/member /var/lib/etcd/
mv /root/etcd-restore/*.yaml /etc/kubernetes/manifests/

sleep 15s



for namespace in $(kubectl get namespace -o jsonpath='{.items[*].metadata.name}'); do
    for name in $(kubectl get deployments -n $namespace -o jsonpath='{.items[*].metadata.name}'); do
        kubectl patch deployment -n ${namespace} ${name} -p '{"spec":{"template":{"metadata":{"annotations":{"ca-rotation": "1"}}}}}';
    done
    for name in $(kubectl get daemonset -n $namespace -o jsonpath='{.items[*].metadata.name}'); do
        kubectl patch daemonset -n ${namespace} ${name} -p '{"spec":{"template":{"metadata":{"annotations":{"ca-rotation": "1"}}}}}';
    done
done

base64_encoded_ca="$(base64 -w0 /etc/kubernetes/pki/ca.crt)"

kubectl get cm/cluster-info --namespace kube-public -o yaml | \
    /bin/sed "s/\(certificate-authority-data:\).*/\1 ${base64_encoded_ca}/" | \
    kubectl apply -f -

