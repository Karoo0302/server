#apt-get install -y etcd

backup_now=`date +"%FT%R"`
rm_now=`date +"%FT%R" -d '12 hour ago'`

ETCDCTL_API=3 etcdctl snapshot save ${backup_now}_etcd.db \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key
echo "ETCD database backup complete"

rm -rf ${rm_now}_etcd.db
echo "rm -rf etcd success"
