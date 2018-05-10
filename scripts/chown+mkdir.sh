#/bin/bash
cd ${HOME}
sudo rm -r ./proyecto
git clone https://github.com/ahsan0786/proyecto.git
if [[ -f /home/ubuntu/docker/containers/mysql ]] && [[ -f /home/ubuntu/docker/containers/joomla ]] && [[ -f /home/ubuntu/docker/containers/mysql-config ]]; then
	sudo rm -r /home/ubuntu/docker/containers/mysql
	sudo rm -r /home/ubuntu/docker/containers/joomla
	sudo rm -r /home/ubuntu/docker/containers/mysql-config
else 
	sudo mkdir /home/ubuntu/docker/containers/mysql
	sudo mkdir /home/ubuntu/docker/containers/mysql-config
	sudo mkdir /home/ubuntu/docker/containers/joomla
	sudo chown 999:docker /home/ubuntu/docker/containers/mysql
	sudo chown 999:docker /home/ubuntu/docker/containers/mysql-config
	sudo chown www-data:www-data /home/ubuntu/docker/containers/joomla
	sudo cp -a ${HOME}/proyecto/config/my.cnf /home/ubuntu/docker/containers/mysql-config 
fi
