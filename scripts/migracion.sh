#/bin/bash
echo ""
echo ""
echo "-------------------------------------------"
echo "M I G R A C I O N   D E   W O R D P R E S S"
echo "-------------------------------------------"
echo ""
echo ""

#VARIABLES IMPORTANTES

# peticions de variables de la maquina cliente

echo "Dime la IP MYSQL de tu máquina "
read MYSQL_IP_CLIENTE
echo "Dime la IP WORDPRESS de tu máquina"
read WORDPRESS_IP_CLIENTE
echo "Usuario de DB de tu maquina"
read USUARIO_DB_CLIENTE
echo "Contraseña de DB de tu maquina"
read PASS_DB_CLIENTE
echo "Nombre de la DB de tu maquina"
read NOMBRE_DB_CLIENTE

# copias de seguridad de la maquina cliente
mysqldump --host $MYSQL_IP_CLIENTE -u$USUARIO_DB_CLIENTE -p$PASS_DB_CLIENTE $NOMBRE_DB_CLIENTE > $NOMBRE_DB_CLIENTE.sql

echo "PATH del directorio wp-content"
read WP_CONTENT_CLIENTE
echo "Nombre de usuario de la máquina"
read USUARIO_MAQUINA_CLIENTE

rsync -avzhe ssh $USUARIO_MAQUINA_CLIENTE@$WORDPRESS_IP_CLIENTE:$WP_CONTENT_CLIENTE ./wp-content
#peticion de variables de la maquina migracion

echo "Usuario máquina migracion"
read USUARIO_MAQUINA_MIGRACION
echo "PATH  MYSQL de la maquina migracion"
read PATH_DB_MIGRACION
echo "Contraseña de la DB de migracion"
read PASS_DB_MIGRACION
echo "IP MYSQL de la maquina migracion"
read MYSQL_IP_MIGRACION
echo "IP WORDPRESS de la maquina migracion"
read WORDPRESS_IP_MIGRACION

#inserccion de la copia de seguridad a la maquina migracion
#rsync -avzhe ssh $NOMBRE_DB_CLIENTE.sql $USUARIO_MAQUINA_MIGRACION@$MYSQL_IP_MIGRACION:$PATH_DB_MIGRACION
mysql --host $MYSQL_IP_MIGRACION -uroot -p$PASS_DB_MIGRACION -e 'DROP DATABASE wordpress';
mysql --host $MYSQL_IP_MIGRACION -uroot -p$PASS_DB_MIGRACION -e 'CREATE DATABASE wordpress';
mysql -h $MYSQL_IP_MIGRACION -u root -p  $NOMBRE_DB_CLIENTE < $NOMBRE_DB_CLIENTE.sql
#sincronizacion de la carpeta wordpress a la maquina master
ssh -t $USUARIO_MAQUINA_MIGRACION@$WORDPRESS_IP_MIGRACION "/usr/bin/sudo rm -r /home/ubuntu/docker/containers/wordpress/wp-content && /usr/bin/sudo mkdir /home/ubuntu/docker/containers/wordpress/wp-content && /usr/bin/sudo chmod 777 /home/ubuntu/docker/containers/wordpress/wp-content "
rsync -avzhe ssh ./wp-content/ $USUARIO_MAQUINA_MIGRACION@$WORDPRESS_IP_MIGRACION:/home/ubuntu/docker/containers/wordpress/wp-content/

