#/bin/bash
cd ${HOME}
sudo rm -r ./proyecto
git clone https://github.com/ahsan0786/proyecto.git
if [ -f /home/ubuntu/docker/containers/haproxy ]; then
        sudo rm -r /home/ubuntu/docker/containers/haproxy
else
        sudo mkdir /home/ubuntu/docker/containers/haproxy
        sudo cp -a ${HOME}/proyecto/config/haproxy.cfg /home/ubuntu/docker/containers/haproxy

fi

