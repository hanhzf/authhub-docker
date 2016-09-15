# Docker Image for AuthHub

This image will help setup all the packages dependency and prepare the working environment for authhub.

# prepare memcache and postgresql

  * you should have a memcache service and postgresql service
  * you should create database for AuthHub Service with dbname 'authhub' user 'authhubadm':

    ```
    create user authhubadm with password 'your_db_password'  
    create database authhub owner authhubadm
    ```

# prepare build volume and make package for authhub

  * create a folder <authhub_build_dir> on host server
  * clone authhub project sourcecode to <authhub_build_dir>
  * the folder tree looks like:
    ```
      + <authhub_build_dir>
        - authhub
          - authhub
          - commutils
          - ...
    ```
  * package this file with:
    ```
    cd <authhub_build_dir>/authhub/
    tar zcf <authhub_build_dir>/authhub.tgz authhub/
    ```

# Build the Docker Image

clone this project and go to the authhub-docker folder, and build the image:

  ```
  docker build -t authhub .
  ```

# Environment Variables Description

  * MEMCACHE_HOST

    host address for memcache server, like "10.70.44.118:11211".  
    If memcache server is a cluster, separate them with ",", like "10.70.44.118:11211, 10.70.44.119:11211"

  * POSTGRES_HOST

    host address for postgresql, like "10.70.44.118"

  * POSTGRES_PASS

    password for postgresql

  * NEED_INIT_DB

    whether we need create database, if "yes", docker startup scripts will try to create tables for AuthHub service

# Run docker instances

  If the table has not initialized, you need startup the container with NEED_INIT_DB='yes' environment, this
  will create all the tables for AuthHub:

  `
  docker run -d -e NEED_INIT_DB="yes" -e MEMCACHE_HOST=<your_memcache_server_ip_address> -e POSTGRES_HOST=<your_postgresql_server_ip_address> -e POSTGRES_PASS= -v <authhub_build_dir>:/opt/build -p 5000:5000 authhub
  `

  else if you have already created the database, or you want to start a cluster of authhub service under a load-banlancer, start contaier without
  NEED_INIT_DB environment or with NEED_INIT_DB='no':


  `
  docker run -d -e MEMCACHE_HOST=<your_memcache_server_ip_address> -e POSTGRES_HOST=<your_postgresql_server_ip_address> -e POSTGRES_PASS= -v <authhub_build_dir>:/opt/build -p 5000:5000 authhub
  `

  You will met problems like "db is not up to date" if you try to init db multiple times.

# check service ok

  * docker inspect YOUR_DOKCER_CONTAINER_ID to get your container's ip address YOUR_DOKCER_CONTAINER_IP
  * curl http://YOUR_DOKCER_CONTAINER_IP:5000/v1/users/ to check service response
