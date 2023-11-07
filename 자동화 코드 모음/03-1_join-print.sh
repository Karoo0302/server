echo "cluster join (for worker) : "
kubeadm token create --print-join-command

echo "Master 2 IP:"
read master2

echo "Master 3 IP:"
read master3


cert_key=`kubeadm init phase upload-certs --upload-certs | tail -1`
echo -e "\nHA cluster join (for master) : "
command1=`kubeadm token create --print-join-command --certificate-key $cert_key | cut -d ' ' -f1-3`
command3=`kubeadm token create --print-join-command --certificate-key $cert_key | cut -d ' ' -f4-`

master2_join="$command1 --apiserver-advertise-address=$master2 $command3"
master3_join="$command1 --apiserver-advertise-address=$master3 $command3"

echo "$master2_join"
echo "$master3_join"
