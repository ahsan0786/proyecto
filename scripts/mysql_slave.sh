#!/bin/bash
BASE_PATH=$(dirname $0)
MASTER_IP=192.168.0.18
SLAVE_IP=192.168.0.19
MYSQL_SLAVE_PASSWORD=Ausias123@@
MYSQL_MASTER_PASSWORD=Ausias123@@
MYSQL_REPLICATION_PASSWORD=Ausias123@@
MYSQL_REPLICATION_USER=root
echo "Waiting for mysql to get up"
# Give 60 seconds for master and slave to come up
sleep 3

echo "Create MySQL Servers (master / slave repl)"
echo "-----------------"


echo "* Create replication user"

mysql --host $SLAVE_IP -uroot -p$MYSQL_SLAVE_PASSWORD  -e 'STOP SLAVE;';
mysql --host $SLAVE_IP -uroot -p$MYSQL_MASTER_PASSWORD -e 'RESET SLAVE ALL;';

mysql --host $MASTER_IP -uroot -p$MYSQL_MASTER_PASSWORD -e "CREATE USER '$MYSQL_REPLICATION_USER'@'%';"
mysql --host $MASTER_IP -uroot -p$MYSQL_MASTER_PASSWORD -e "GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_REPLICATION_USER'@'%' IDENTIFIED BY '$MYSQL_REPLICATION_PASSWORD';"
mysql --host $MASTER_IP -uroot -p$MYSQL_MASTER_PASSWORD -e 'flush privileges;'


echo "* Set MySQL01 as master on MySQL02"

MYSQL01_Position=$(eval "mysql --host $MASTER_IP -uroot -p$MYSQL_MASTER_PASSWORD -e 'show master status \G' | grep Position | sed -n -e 's/^.*: //p'")
MYSQL01_File=$(eval "mysql --host $MASTER_IP -uroot -p$MYSQL_MASTER_PASSWORD -e 'show master status \G'     | grep File     | sed -n -e 's/^.*: //p'")
echo $MASTER_IP
mysql --host $SLAVE_IP -uroot -p$MYSQL_SLAVE_PASSWORD -e "CHANGE MASTER TO master_host='$MASTER_IP', master_port=3306, \
        master_user='$MYSQL_REPLICATION_USER', master_password='$MYSQL_REPLICATION_PASSWORD', master_log_file='$MYSQL01_File', \
        master_log_pos=$MYSQL01_Position;"

echo "* Set MySQL02 as master on MySQL01"

MYSQL02_Position=$(eval "mysql --host $SLAVE_IP -uroot -p$MYSQL_SLAVE_PASSWORD -e 'show master status \G' | grep Position | sed -n -e 's/^.*: //p'")
MYSQL02_File=$(eval "mysql --host $SLAVE_IP -uroot -p$MYSQL_SLAVE_PASSWORD -e 'show master status \G'     | grep File     | sed -n -e 's/^.*: //p'")

#SLAVE_IP=$(eval "getent hosts $SLAVE_IP|awk '{print \$1}'")
echo $SLAVE_IP
mysql --host $MASTER_IP -uroot -p$MYSQL_MASTER_PASSWORD -e "CHANGE MASTER TO master_host='$SLAVE_IP', master_port=3306, \
        master_user='$MYSQL_REPLICATION_USER', master_password='$MYSQL_REPLICATION_PASSWORD', master_log_file='$MYSQL02_File', \
        master_log_pos=$MYSQL02_Position;"

echo "* Start Slave on both Servers"
mysql --host $SLAVE_IP -uroot -p$MYSQL_SLAVE_PASSWORD -e "start slave;"

echo "Increase the max_connections to 2000"
mysql --host $MASTER_IP -uroot -p$MYSQL_MASTER_PASSWORD -e 'set GLOBAL max_connections=2000';
mysql --host $SLAVE_IP -uroot -p$MYSQL_SLAVE_PASSWORD -e 'set GLOBAL max_connections=2000';

mysql --host $SLAVE_IP -uroot -p$MYSQL_MASTER_PASSWORD -e "show slave status \G"

echo "MySQL servers created!"
echo "--------------------"
echo
echo Variables available fo you :-
echo
echo MYSQL01_IP       : $MASTER_IP
echo MYSQL02_IP       : $SLAVE_IP
