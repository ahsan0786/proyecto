#!/bin/bash
apt-get update
cd /tmp
apt-get install influxdb
wget https://dl.influxdata.com/telegraf/releases/telegraf_1.6.2-1_amd64.deb
sudo dpkg -i telegraf_1.6.2-1_amd64.deb


