#!/bin/bash
## FLUSH de regles
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
## política permissiva
iptables -P INPUT       ACCEPT
iptables -P OUTPUT      ACCEPT
iptables -P FORWARD     ACCEPT
iptables -t nat -P PREROUTING   ACCEPT
iptables -t nat -P POSTROUTING  ACCEPT
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward
