#/bin/bash
cd ${HOME}
sudo rm -r ./proyecto
git clone https://github.com/ahsan0786/proyecto.git
if [[ -f /home/ubuntu/docker/containers/mysql ]] && [[ -f /home/ubuntu/docker/containers/wordpress ]] && [[ -f /home/ubuntu/docker/containers/mysql-config$
        sudo rm -r /home/ubuntu/docker/containers/mysql
        sudo rm -r /home/ubuntu/docker/containers/wordpress
        sudo rm -r /home/ubuntu/docker/containers/mysql-config
else 
        sudo mkdir /home/ubuntu/docker/containers/mysql
        sudo mkdir /home/ubuntu/docker/containers/mysql-config
        sudo mkdir /home/ubuntu/docker/containers/wordpress
        sudo cp -a ${HOME}/proyecto/config/my.cnf /home/ubuntu/docker/containers/mysql-config 
fi

