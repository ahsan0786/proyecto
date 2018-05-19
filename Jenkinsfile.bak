env.DOCKERHUB_USERNAME = 'ahsan0786'
  node("docker-test") {
    checkout scm
    stage("Integration Test") {
      try {
        sh " docker run --restart=always --name mysql -p 3307:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql "
     sh "docker run --rm --name wordpress --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/wordpress:/var/www/html -e network_mode=proyecto -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_wordpress"
		}
      catch(e) {
        error "Integration Test failed"
      }finally {
        sh "docker rm -f wordpress || true"
        sh "docker rm -f mysql || true"
        sh "docker ps -aq | xargs docker rm || true"
      }
    }
    stage("Publish") {
      withDockerRegistry([credentialsId: 'DockerHub']) {
		sh "docker tag ahsan0786/proyecto_mysql ahsan0786/proyecto_mysql"
		sh "docker tag ahsan0786/proyecto_wordpress ahsan0786/proyecto_wordpress"
		sh "docker push ahsan0786/proyecto_mysql"
		sh "docker push ahsan0786/proyecto_wordpress"
      }
    }
  }

  node("docker-stage") {
    checkout scm

    stage("Staging") {
      try {
        sh " docker run --restart=always --name mysql -p 3307:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql "
	sh "docker run --rm --name wordpress --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/wordpress:/var/www/html -e network_mode=proyecto -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_wordpress"
      } catch(e) {
        error "Staging failed"
      } finally {
		sh "docker stop mysql wordpress && docker rm mysql|| true"
	        sh "docker ps -aq | xargs docker rm || true"
		sh "docker rmi ahsan0786/proyecto_mysql"
		sh "docker rmi ahsan0786/proyecto_wordpress"
      }
    }
  }

  node("docker-prod") {
    stage("Production") {
      try {
        // Create the service if it doesn't exist otherwisejust update the image
        sh '''
         SERVICES=$(docker service ls --filter name=proyecto_mysql --quiet | wc -l)
	 SERVICES1=$(docker service ls --filter name=proyecto_wordpress --quiet | wc -l)
          if [[ "$SERVICES" -eq 0 ]] && [[ "$SERVICES1" -eq 0 ]] ; then
		docker network rm proyecto || true
		docker network create --driver overlay --attachable proyecto
		docker service create --replicas 1 --network proyecto --name proyecto_mysql -p 3306:3306 --mount type=bind,source=/home/ubuntu/docker/containers/mysql,destination=/var/lib/mysql --mount type=bind,source=/home/ubuntu/docker/containers/mysql-config/my.cnf,destination=/etc/mysql/my.cnf -e MYSQL_ROOT_PASSWORD=Ausias123@@ ahsan0786/proyecto_mysql
		docker service create --replicas 3 --network proyecto --name proyecto_wordpress -p 80:80 --mount type=bind,source=/home/ubuntu/docker/containers/wordpress,destination=/var/www/html -e WORDPRESS_DB_HOST=proyecto_mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@ ahsan0786/proyecto_wordpress
          else
		docker service update --image ahsan0786/proyecto_mysql proyecto_mysql
		docker service update --image ahsan0786/proyecto_wordpress proyecto_wordpress 
          fi
          '''
        // run some final tests in production
        checkout scm
        sh '''
          sleep 60s 
          for i in `seq 1 20`;
          do
		STATUS=$(docker service inspect --format '{{ .UpdateStatus.State }}' proyecto_mysql)
		STATUS1=$(docker service inspect --format '{{ .UpdateStatus.State }}' proyecto_wordpress)
            if [[ "$STATUS" != "updating" ]] && [[ "$STATUS1" != "updating" ]]; then
		docker run --restart=always --name mysql -p 3308:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql
		docker run --rm --name wordpress --link mysql:mysql -p 81:80 -v /home/ubuntu/docker/containers/wordpress:/var/www/html -e network_mode=proyecto -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_wordpress
		docker stop mysql wordpress
		docker rm mysql || true
		docker rm mysql wordpress || true
		break
            fi         
            sleep 10s
          done
          
        '''
      }catch(e) {
        sh "docker service update --rollback  proyecto_mysql"
	sh "docker service update --rollback  proyecto_wordpress"
        error "Service update failed in production"
      }
    }
  }
 
  node("docker-prod-slave") {
    stage("Production") {
      try {
        // Create the service if it doesn't exist otherwise just update the image
        sh '''
          SERVICES=$(docker service ls --filter name=proyecto_mysql --quiet | wc -l)
	  SERVICES1=$(docker service ls --filter name=proyecto_wordpress --quiet | wc -l)
          if [[ "$SERVICES" -eq 0 ]] && [[ "$SERVICES1" -eq 0 ]] ; then
		docker network rm proyecto || true
		docker network create --driver overlay --attachable proyecto
		docker service create --replicas 1 --network proyecto --name proyecto_mysql -p 3306:3306 --mount type=bind,source=/home/ubuntu/docker/containers/mysql,destination=/var/lib/mysql  --mount type=bind,source=/home/ubuntu/docker/containers/mysql-config/my2.cnf,destination=/etc/mysql/my.cnf -e MYSQL_ROOT_PASSWORD=Ausias123@@ ahsan0786/proyecto_mysql
		docker service create --replicas 3 --network proyecto --name proyecto_wordpress -p 80:80 --mount type=bind,source=/home/ubuntu/docker/containers/wordpress,destination=/var/www/html -e WORDPRESS_DB_HOST=proyecto_mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@ ahsan0786/proyecto_wordpress
          else
		docker service update --image ahsan0786/proyecto_mysql proyecto_mysql
            	docker service update --image ahsan0786/proyecto_wordpress proyecto_wordpress
          fi
          '''
        // run some final tests in production
        checkout scm
        sh '''
          sleep 60s 
          for i in `seq 1 20`;
          do
		STATUS=$(docker service inspect --format '{{ .UpdateStatus.State }}' proyecto_mysql)
		STATUS1=$(docker service inspect --format '{{ .UpdateStatus.State }}' proyecto_wordpress)
            	if [[ "$STATUS" != "updating" ]] && [[ "$STATUS1" != "updating" ]]; then
			docker run --restart=always --name mysql -p 3308:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql
			docker run --rm --name wordpress --link mysql:mysql -p 81:80 -v /home/ubuntu/docker/containers/wordpress:/var/www/html -e network_mode=proyecto -e WORDPRESS_DB_HOST=mysql -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_wordpress
			docker stop mysql wordpress
			docker rm mysql || true
			docker rm mysql wordpress || true
			break
	        fi        
            sleep 10s
          done
          
        '''
      }catch(e) {
        sh "docker service update --rollback  proyecto_mysql"
	sh "docker service update --rollback  proyecto_wordpress"
        error "Service update failed in production"
      }
    }
  }

