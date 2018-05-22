#/bin/bash
cd ${HOME}
sudo rm -r ./proyecto
git clone https://github.com/ahsan0786/proyecto.git
if [ -d /home/ubuntu/docker/containers/nginx ]; then
        sudo rm -r /home/ubuntu/docker/containers/nginx
        sudo mkdir /home/ubuntu/docker/containers/nginx
        sudo cp -a ${HOME}/proyecto/config/nginx.conf /home/ubuntu/docker/containers/nginx/

else
        sudo mkdir /home/ubuntu/docker/containers/nginx
        sudo cp -a ${HOME}/proyecto/config/nginx.conf /home/ubuntu/docker/containers/nginx/

fi

