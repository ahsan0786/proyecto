echo "cúal es la ip del container?"
read ip_www
echo "como es el dominio?"
read dns
address="address=/$dns/$ip_www"
echo $address >>/home/ubuntu/docker/containers/dnsmasq/dnsmasq.conf
docker restart dnsmasq

