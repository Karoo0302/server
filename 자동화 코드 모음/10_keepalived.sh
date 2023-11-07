#apt update

apt-get install -y keepalived

echo "Node Role :"
echo "ex) MASTER or BACKUP"

read role

echo "USE NIC"
echo "ex) ens37"
read nic

echo "VIP"
read vip


echo "
global_defs {
   router_id rtr_0           # Master와 Backup 구분
}
vrrp_instance VI_0 {          # Master와 Backup과 구분
    state $role              # 또는 BACKUP
    interface $nic            # 노드에서 실제 사용할 인터페이스 지정
    virtual_router_id 10      # Master와 Backup 모두 같은 값으로 설정.
    priority 100              # 우선순위, 값이 높은 쪽인 Master가 된다.
    advert_int 1
    authentication {
        auth_type PASS        # Master와 Backup 모두 같은 값으로 설정.
        auth_pass P@ssW0rd    # Master와 Backup 모두 같은 값으로 설정.
    }
    virtual_ipaddress {
        $vip      # Master와 Backup 동일하게 설정한 VIP
    }
	#notify_master
	#notify_backup
} " >> /etc/keepalived/keepalived.conf
