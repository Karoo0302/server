echo "NFS Server IP :"
read nfs

echo "NFS Server Directory :"
read dir

echo "Restore HAProxy conf"

scp -r user01@$nfs:$dir/* /etc/haproxy/

echo "Restore done"
