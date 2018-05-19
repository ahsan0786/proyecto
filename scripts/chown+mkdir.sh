#/bin/bash
cd ${HOME}
sudo rm -r ./proyecto
git clone https://github.com/ahsan0786/proyecto.git
if [ -d /home/ubuntu/docker/containers/mysql ] && [ -d /home/ubuntu/docker/containers/wordpress ] && [ -d /home/ubuntu/docker/containers/mysql-config ]; then
        sudo rm -r /home/ubuntu/docker/containers/mysql
        sudo rm -r /home/ubuntu/docker/containers/wordpress
        sudo rm -r /home/ubuntu/docker/containers/mysql-config
        sudo mkdir /home/ubuntu/docker/containers/mysql
        sudo mkdir /home/ubuntu/docker/containers/mysql-config
        sudo mkdir /home/ubuntu/docker/containers/wordpress
        sudo cp -a ${HOME}/proyecto/config/my.cnf /home/ubuntu/docker/containers/mysql-config
        sudo cp -a ${HOME}/proyecto/config/my2.cnf /home/ubuntu/docker/containers/mysql-config

else
        sudo mkdir /home/ubuntu/docker/containers/mysql
        sudo mkdir /home/ubuntu/docker/containers/mysql-config
        sudo mkdir /home/ubuntu/docker/containers/wordpress
        sudo cp -a ${HOME}/proyecto/config/my.cnf /home/ubuntu/docker/containers/mysql-config
        sudo cp -a ${HOME}/proyecto/config/my2.cnf /home/ubuntu/docker/containers/mysql-config

fi

