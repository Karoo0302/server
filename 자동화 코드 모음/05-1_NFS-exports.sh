
apt-get install -y nfs-common

echo "Mount Directory :"
read mnt_dir

echo "NFS-IP Address :"
read nfs_ip

echo "NFS-IP Subnet : ex) 172.26.18.0/24"
read nfs_subnet

echo "NFS Folder :"
read nfs_path

echo -e "\nDo make Share Folder NFS & exports"
echo -e "mkdir $nfs_path && echo \"$nfs_path $nfs_subnet(rw,no_subtree_check,no_root_squash)\" >> /etc/exports && exportfs -r\n"

echo "Press Enter.."
read enter

mount $nfs_ip:$nfs_path $mnt_dir

echo "$nfs_ip:$nfs_path $mnt_dir nfs rw 0 0" >> /etc/fstab
