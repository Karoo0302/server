kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

cd /var/lib/kubelet

echo "serverTLSBootstrap: true" >> config.yaml
systemctl restart kubelet

echo -e "\nDo other k8s nodes apply this command"
echo -e "echo "serverTLSBootstrap: true" >> /var/lib/kubelet/config.yaml && systemctl restart kubelet\n"

echo "Press Enter..."
read enter

csr=(`kubectl get csr | awk '/csr-/' | awk -F ' ' '{print $1}'`)
csr_num=`echo ${#csr[@]}`


for ((i=0; i<$csr_num; i++))
do
        kubectl certificate approve ${csr[i]}
done

kubectl get csr
