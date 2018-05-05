#echo "pega el comando docker swarm join...."
#read swarm
#bash -c "$swarm"
docker swarm init
echo "IP jenkins master"
read ipmaster
echo "username jenkins master"
read user
echo "password jenkins master"
read password
echo "-master http://$ipmaster:8082 -password $password -username $user"|docker secret create jenkins-v1 -
docker service create \
    --mode=global \
    --name jenkins-swarm-agent \
    -e LABELS=docker-prod \
    --mount "type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock" \
    --mount "type=bind,source=/tmp/,target=/tmp/" \
    --secret source=jenkins-v1,target=jenkins \
    vipconsult/jenkins-swarm-agent
