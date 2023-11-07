apt update
apt-get install -y haproxy

echo -e 'CONFIG="/etc/haproxy/"' >> /etc/default/haproxy

systemctl restart haproxy
