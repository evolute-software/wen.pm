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

echo "Deploying: $PRJ"

# use ./* to skip hidden files like .git
rsync -avuz ./* ${HOST}:/opt/web/${PRJ}/

INSTALL="cd /opt/web/$PRJ && 
  docker-compose build &&
	docker-compose up -d --force-recreate &&
	mv ${PRJ}.conf /etc/nginx/virtual-hosts/ &&
	systemctl restart nginx"

ssh $HOST  "bash -c '$INSTALL'"

