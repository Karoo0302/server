apt-get install -y nfs-common

echo "NFS Server IP :"
read nfs

echo "NFS Server Directory :"
read dir

echo "Restore Proxy Name :"
read name

scp -r user01@$nfs:$dir/$name/* /etc/nginx/sites-enabled/

echo "Restore done"
