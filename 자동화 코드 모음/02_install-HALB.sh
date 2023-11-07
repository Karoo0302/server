apt update

apt-get install -y haproxy

echo "This node IP:port : "
read LB
echo "node 1 IP:port : "
read node1
echo "node 2 IP:port : "
read node2
echo "node 3 IP:port : "
read node3


echo "
frontend kubernetes-master-lb
        bind $LB
        option tcplog
        mode tcp
        default_backend kubernetes-master-nodes

backend kubernetes-master-nodes
        mode tcp
        balance roundrobin
        option tcp-check
        option tcplog
        server node1 $node1 check #check masternode
        server node2 $node2 check
        server node3 $node3 check
" >> /etc/haproxy/haproxy.cfg

service haproxy reload
