#git_id=Karoo302
#git_token=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
#git_repo=github.com/lawdians-infra/nfs-provisioner.git

apt-get install -y nfs-kernel-server

#git clone https://$git_id:$git_token@$git_repo

cd nfs-provisioner

echo "NFS-SERVER IP : "
read nfs_ip
echo "NFS-PATH : "
read nfs_path

sed -i "s/nfs-ip/$nfs_ip/g" deploy.yaml
sed -i "s|nfs-path|$nfs_path|g" deploy.yaml

kubectl apply -f class.yaml
kubectl apply -f rbac.yaml
kubectl apply -f deploy.yaml

