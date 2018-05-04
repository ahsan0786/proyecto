env.DOCKERHUB_USERNAME = 'ahsan0786'

  node("docker-test") {
    checkout scm

 //   stage("Unit Test") {
   //!   sh "docker run --rm -v ${WORKSPACE}:proyecto -v --run Unit"
  //  }
    stage("Integration Test") {
      try {
        sh "docker build -t proyecto_mysql -f Dockerfile_mysql . "
		sh "docker build -t proyecto_joomla -f Dockerfile_joomla . "
		sh "docker rm -f joomla || true"
        sh "docker rm -f mysql || true"
        sh " docker run --restart=always --name mysql -p 3307:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql/data -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql "
		//sh " docker run --restart=always --name joomla --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/joomla:/var/www/html -e network_mode=proyecto -e JOOMLA_DB_HOST=mysql -e JOOMLA_DB_USER=root -e JOOMLA_DB_PASSWORD=Ausias123@@ -d proyecto_joomla "
        // env variable is used to set the server where go test will connect to run the test
       // sh "docker run --rm -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql/data -e MYSQL_ROOT_PASSWORD=Ausias123@@ proyecto_mysql -v --run proyecto_mysql"
		//sh " docker run --rm --name joomla --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/joomla:/var/www/html -e network_mode=proyecto -e JOOMLA_DB_HOST=mysql -e JOOMLA_DB_USER=root -e /JOOMLA_DB_PASSWORD=Ausias123@@ --run proyecto_joomla "
     sh "docker run --rm --name joomla --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/joomla:/var/www/html -e network_mode=proyecto -e JOOMLA_DB_HOST=mysql -e JOOMLA_DB_USER=root -e JOOMLA_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_joomla "
		}
      catch(e) {
        error "Integration Test failed"
      }finally {
        sh "docker rm -f joomla || true"
        sh "docker rm -f mysql || true"
        sh "docker ps -aq | xargs docker rm || true"
        sh "docker images -aq -f dangling=true | xargs docker rmi || true"
      }
    }
    stage("Build") {
        sh "docker build -t proyecto_mysql -f Dockerfile_mysql . "
		sh "docker build -t proyecto_joomla -f Dockerfile_joomla . "
    }
    stage("Publish") {
      withDockerRegistry([credentialsId: 'DockerHub']) {
		//sh "proyecto_mysql=$(docker images | grep proyecto_mysql |awk '{print $3}')"
		//sh "proyecto_joomla=$(docker images | grep proyecto_joomla |awk '{print $3}')"
		sh "docker tag proyecto_mysql ahsan0786/proyecto_mysql"
		sh "docker tag proyecto_joomla ahsan0786/proyecto_mysql"
		sh "docker push ahsan0786/proyecto_mysql"
		sh "docker push ahsan0786/proyecto_mysql"
      }
    }
  }

  node("docker-stage") {
    checkout scm

    stage("Staging") {
      try {
        sh "docker rm -f joomla || true"
        sh "docker rm -f mysql || true"
        sh " docker run --restart=always --name mysql -p 3307:3306 -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql/data -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql "
		//sh " docker run --restart=always --name joomla --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/joomla:/var/www/html -e network_mode=proyecto -e JOOMLA_DB_HOST=mysql -e JOOMLA_DB_USER=root -e JOOMLA_DB_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_joomla "
       // sh "docker run --rm -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql/data -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ ahsan0786/proyecto_mysql -v"
		//sh "docker run --rm -v /home/ubuntu/docker/containers/joomla:/var/www/html -e network_mode=proyecto -e JOOMLA_DB_HOST=mysql -e JOOMLA_DB_USER=root -e JOOMLA_DB_PASSWORD=Ausias123@@ ahsan0786/proyecto_joomla -v"
		sh "docker run --rm --name joomla --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/joomla:/var/www/html -e network_mode=proyecto -e JOOMLA_DB_HOST=mysql -e JOOMLA_DB_USER=root -e JOOMLA_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_joomla "
      } catch(e) {
        error "Staging failed"
      } finally {
        sh "docker rm -f joomla || true"
        sh "docker rm -f mysql || true"
        sh "docker ps -aq | xargs docker rm || true"
        sh "docker images -aq -f dangling=true | xargs docker rmi || true"
      }
    }
  }

  node("docker-prod") {
    stage("Production") {
      try {
        // Create the service if it doesn't exist otherwise just update the image
        sh '''
          SERVICES=$(docker service ls --filter name=proyecto_mysql --quiet | wc -l)
		  SERVICES1=$(docker service ls --filter name=proyecto_joomla --quiet | wc -l)
          if [[ "$SERVICES" -eq 0 ]] && [[ "$SERVICES1" -eq 0 ]] ; then
	        docker network rm proyecto || true
            docker network create --driver overlay --attachable proyecto
			docker service create --replicas 3 --network proyecto --name proyecto_mysql -p 3307:3306 ahsan0786/proyecto_mysql
			docker service create --replicas 3 --network proyecto --name proyecto_joomla -p 8080:80 ahsan0786/proyecto_joomla
          else
			docker service update --image ahsan0786/proyecto_mysql ahsan0786/proyecto_mysql
            docker service update --image ahsan0786/proyecto_joomla ahsan0786/proyecto_joomla 
          fi
          '''
        // run some final tests in production
        checkout scm
        sh '''
          sleep 60s 
          for i in `seq 1 20`;
          do
            STATUS=$(docker service inspect --format '{{ .UpdateStatus.State }}' proyecto_mysql)
			STATUS1=$(docker service inspect --format '{{ .UpdateStatus.State }}' proyecto_joomla)
            if [[ "$STATUS" != "updating" ]] && [[ "$STATUS1" != "updating" ]]; then
				docker run --rm -v /home/ubuntu/docker/containers/mysql:/var/lib/mysql/data -e network_mode=proyecto -e MYSQL_ROOT_PASSWORD=Ausias123@@ -d ahsan0786/proyecto_mysql
				docker run --rm --name joomla --link mysql:mysql -p 8080:80 -v /home/ubuntu/docker/containers/joomla:/var/www/html -e network_mode=proyecto -e JOOMLA_DB_HOST=mysql -e JOOMLA_DB_USER=root -e JOOMLA_DB_PASSWORD=Ausias123@@  -d ahsan0786/proyecto_joomla
				break
            fi         
            sleep 10s
          done
          
        '''
      }catch(e) {
        sh "docker service update --rollback  proyecto_mysql"
		sh "docker service update --rollback  proyecto_joomla"
        error "Service update failed in production"
      }finally {
        sh "docker ps -aq | xargs docker rm || true"
      }
    }
  }
