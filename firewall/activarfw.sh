#!/bin/bash
#FLUSH de regles
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
#politica restrictiva
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
#commutacio
echo 1 > /proc/sys/net/ipv4/ip_forward
#variables
RED_INTERNET=192.168.205.0/24
RED_SERVER=192.168.104.0/24
RED_CLIENTES=192.168.105.0/24
INTERFAZ_SWITCH_SERVER=enp0s9
INTERFAZ_SWITCH_CLIENTES=enp0s8
INTERFAZ_INTERNET=enp0s3
ipfwcli=192.168.105.144
port_ssh=22
port_web=80
port_web1=80
port_web2=443
port_web3=8080
port_moni=8086
port_dns=53
port_portainer_srv=9000
port_jenkins=5000
port_jenkins2=50000

#establecer conexiones
iptables -A INPUT   -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT

##enrutament
iptables -t nat -A POSTROUTING -o $INTERFAZ_INTERNET -j MASQUERADE
#treballadors poden accedir al DNS i WEB i sortir a navegar
#WEB
iptables -A INPUT -i $INTERFAZ_SWITCH_SERVER -p tcp --dport $port_web -m state --state NEW -j ACCEPT
iptables -A INPUT -i $INTERFAZ_SWITCH_CLIENTES -p tcp --dport $port_web -m state --state NEW -j ACCEPT
iptables -A FORWARD -s $RED_CLIENTES -i $INTERFAZ_SWITCH_CLIENTES -p tcp --dport $port_web -j ACCEPT
iptables -A FORWARD -s $RED_CLIENTES -i $INTERFAZ_INTERNET -p tcp --dport $port_web1 -j ACCEPT
iptables -A FORWARD -i $INTERFAZ_INTERNET -o $INTERFAZ_SWITCH_CLIENTES -j ACCEPT
#WEB SERVER
iptables -A FORWARD -p tcp --dport $port_web -o $INTERFAZ_SWITCH_SERVER -j ACCEPT
#WEB INTERNET
iptables -A FORWARD -p tcp --dport $port_web1 -o $INTERFAZ_INTERNET -j ACCEPT
iptables -A FORWARD -p tcp --dport $port_web2 -o $INTERFAZ_INTERNET -j ACCEPT
iptables -A FORWARD -p tcp --dport $port_web3 -o $INTERFAZ_INTERNET -j ACCEPT
iptables -A FORWARD -i $INTERFAZ_INTERNET -j ACCEPT
iptables -A FORWARD -o $INTERFAZ_INTERNET -j ACCEPT
#DNS
iptables -A FORWARD -p udp --dport $port_dns -o $INTERFAZ_SWITCH_SERVER -j ACCEPT
iptables -A FORWARD -p udp --dport $port_dns -o $INTERFAZ_SWITCH_CLIENTES -j ACCEPT

#ping
iptables -A INPUT -p ICMP -s $RED_CLIENTES -j ACCEPT

#Permitir ICMP desde la red externa.
iptables -A INPUT -p icmp -i $INTERFAZ_SWITCH_SERVER --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -i $INTERFAZ_SWITCH_SERVER -p ICMP -j ACCEPT
iptables -A OUTPUT -o $INTERFAZ_SWITCH_SERVER -p ICMP -j ACCEPT
iptables -A INPUT -i $INTERFAZ_SWITCH_CLIENTES -p ICMP -j ACCEPT
iptables -A OUTPUT -o $INTERFAZ_SWITCH_CLIENTES -p ICMP -j ACCEPT
iptables -A INPUT -i $INTERFAZ_INTERNET -p ICMP -j ACCEPT
iptables -A OUTPUT -o $INTERFAZ_INTERNET -p ICMP -j ACCEPT
#iptables -A INPUT -d $ipservers -p icmp -j ACCEPT
iptables -A INPUT -d $ipfwcli -p icmp -j ACCEPT
iptables -A OUTPUT -d $RED_SERVER -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A FORWARD -s $RED_CLIENTES -d $RED_SERVER -p icmp -j ACCEPT
iptables -A FORWARD -s $RED_SERVER -d $RED_CLIENTES -p icmp -j ACCEPT

#puerto 9000 portainer de todos los servidores docker
##connexion portainer al loadb ip 192.168.105.143 que te el port 9001
iptables -t nat -A PREROUTING -p tcp -d 192.168.205.144/24 --dport 9001 -j DNAT --to 192.168.105.143:9001
iptables -A INPUT -i $INTERFAZ_INTERNET -p tcp --dport 9001 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $INTERFAZ_INTERNET -p tcp --sport 9001 -m state --state ESTABLISHED -j ACCEPT

##connexion portainer al Master host ip 192.168.105.146 que te el port 9002
iptables -t nat -A PREROUTING -p tcp -d 192.168.205.144/24 --dport 9002 -j DNAT --to 192.168.105.146:9000
iptables -A INPUT -i $INTERFAZ_INTERNET -p tcp --dport 9002 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $INTERFAZ_INTERNET -p tcp --sport 9002 -m state --state ESTABLISHED -j ACCEPT

##connexion portainer al slave host ip 192.168.105.145 que te el port 9003
iptables -t nat -A PREROUTING -p tcp -d 192.168.205.144/24 --dport 9003 -j DNAT --to 192.168.105.145:9000
iptables -A INPUT -i $INTERFAZ_INTERNET -p tcp --dport 9003 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o $INTERFAZ_INTERNET -p tcp --sport 9003 -m state --state ESTABLISHED -j ACCEPT

#iptables -A FORWARD -p tcp --dport $port_portainer_srv -o $INTERFAZ_SWITCH_CLIENTES -j ACCEPT
#iptables -A FORWARD -p tcp --dport $port_portainer_srv -o $INTERFAZ_SWITCH_SERVER -j ACCEPT
#iptables -A FORWARD -p tcp --dport $port_portainer_srv -o $INTERFAZ_SWITCH_SERVER -j ACCEPT
#iptables -t nat -A PREROUTING -s 192.168.104.146/24 -p tcp --dport 9000 -j DNAT --to-destination 192.168.205.144:9000
#ssh
##accedir via ssh al tallafocs
iptables -A INPUT -p tcp --dport $port_ssh -i $INTERFAZ_INTERNET -j ACCEPT
iptables -A OUTPUT -p tcp --sport $port_ssh -o $INTERFAZ_INTERNET -j ACCEPT

iptables -A INPUT -p tcp --sport $port_ssh -i $INTERFAZ_SWITCH_CLIENTES -j ACCEPT
iptables -A OUTPUT -p tcp --dport $port_ssh -o $INTERFAZ_SWITCH_CLIENTES -j ACCEPT


##permitir monitorizacion
iptables -A INPUT -p tcp --dport $port_moni -i $INTERFAZ_INTERNET -j ACCEPT
iptables -A OUTPUT -p tcp --sport $port_moni -o $INTERFAZ_INTERNET -j ACCEPT


#iptables -A FORWARD -s 192.168.104.0 -d $RED_CLIENTES -p tcp --dport $port_ssh -j ACCEPT
#iptables -A FORWARD -s 192.168.205.1 -d $RED_SERVIDOR -p tcp --dport $port_ssh -j ACCEPT
#iptables -A FORWARD -s 192.168.105.0 -d $RED_SERVIDOR -p tcp --dport $port_ssh -j ACCEPT
#iptables -A FORWARD -s 192.168.105.0 -d $RED_INTERNET -p tcp --dport $port_ssh -j ACCEPT
#iptables -A INPUT -i $INTERFAZ_SWITCH_CLIENTES -p tcp --dport $port_ssh -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -o $INTERFAZ_SWITCH_CLIENTES -p tcp --sport $port_ssh -m state --state ESTABLISHED -j ACCEPT
#iptables -A INPUT -i $INTERFAZ_SWITCH_SERVER -p tcp --dport $port_ssh -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -o $INTERFAZ_SWITCH_SERVER -p tcp --sport $port_ssh -m state --state ESTABLISHED -j ACCEPT 
#iptables  -A PREROUTING -t nat -p tcp -d $RED_INTERNET --dport 21 -m state --state NEW,ESTABLISHED,RELATED -j DNAT --to 192.168.104.146:22 


#iptables -t nat -A PREROUTING -p tcp -m multiport --dport 1:65535 -i eth0 -d 192.168.104.146 -j DNAT --to-destination 192.168.205.144
#iptables -t nat -A PREROUTING -p udp -m multiport --dport 1:65535 -i eth0 -d 192.168.104.146 -j DNAT --to-destination 192.168.205.144

#iptables -t nat -A POSTROUTING -s 192.168.205.144 -p tcp -m multiport --dport 1:65535 -j SNAT --to 192.168.104.146
#iptables -t nat -A POSTROUTING -s 192.168.205.144 -p udp -m multiport --dport 1:65535 -j SNAT --to 192.168.104.146
