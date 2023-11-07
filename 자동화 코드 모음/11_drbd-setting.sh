apt-get install -y drbd-utils
echo "Your drbd device :"
echo "ex) /dev/sda"

read disk

fdisk $disk

echo "Your nfs 1 nodename,ip:"
echo "ex) nfs01 10.10.10.10"
read -a node1

echo "----------------------------"

echo "Your nfs 2 nodename,ip:"
echo "ex) nfs02 10.10.10.11"
read -a node2

echo "
${node1[1]} ${node1[0]}
${node2[1]} ${node2[0]}
" >> /etc/hosts

echo "
resource "nfs"
{
        protocol C;
        disk {on-io-error detach;}
        syncer {
        }

        on ${node1[0]} {
        device /dev/drbd0;
        disk ${disk}1;
        address ${node1[1]}:7791;
        meta-disk internal;
        }

        on ${node2[0]} {
        device /dev/drbd0;
        disk ${disk}1;
        address ${node2[1]}:7791;
        meta-disk internal;
        }
}" >> /etc/drbd.d/nfs.res

systemctl enable drbd.service

echo "service drbd start"
echo "drbdadm create-md all"
echo "------checking lsblk drbd0 create-----"
echo "drbdadm primary --force all"
echo "----------if retry sync node----------"
echo "drbdadm secondary all"
echo "drbdadm -- --discard-my-data connect all"
echo "----And primary reconnect resources---"
