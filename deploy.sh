#!/bin/bash

##
## A portable script to deploy docker compose based projects
##
## Expects:
##   1. HOST has docker compose
##   2. HOST uses nginx as reverse proxy with virtual hosts in 
##      /etc/nginx/virtual-hosts
##   3. Project has a self contained docker-compose.yml
##
## WARNING:
## while this file seemingly resides in the services.kindstudios.gr repo
## it is being used by many other projects via creative symlinking. Namely:
##   * status.devices.kindstudios.gr
##   * styling.services.kindstudios.gr
##   * and probably many others!
##

cd $( dirname $0 ) 

PRJ=$( basename $PWD )
HOST=hermes.devices.kindstudios.gr


[ $# -gt 0 ] && [ "$1" = "--only-nginx" ] && ONLY_NGINX=true || ONLY_NGINX=false


echo "Syntax:
  $0 --only-nginx

Deploying: $PRJ
"

# use ./* to skip hidden files like .git
ssh ${HOST} mkdir -p /opt/web/${PRJ}
scp docker-compose.yml ${PRJ}.conf ${HOST}:/opt/web/${PRJ}/
rsync -avuz ./assets/ ${HOST}:/opt/web/${PRJ}/assets

if $ONLY_NGINX
then
  INSTALL="cd /opt/web/$PRJ && 
  	mv ${PRJ}.conf /etc/nginx/virtual-hosts/ &&
  	systemctl restart nginx"
else

  docker-compose build
  docker-compose push
  
  INSTALL="cd /opt/web/$PRJ && 
    chown -R 82 assets
    docker-compose pull &&
  	docker-compose up -d --force-recreate &&
  	mv ${PRJ}.conf /etc/nginx/virtual-hosts/ &&
  	systemctl restart nginx"

fi

ssh $HOST  "bash -c '$INSTALL'"

