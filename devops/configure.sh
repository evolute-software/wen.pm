#!/bin/bash

##
## Configure the main frontend for the container and set the window.backendUrl
## and the window.frontendUploadPortalUrl variables
##
echo $0 $@

[ $# -lt 1 ] && echo "Syntax: $0 CMD [ARG1] ... [ARGN]" && exit 1

# Commented out since there is no backend atm
#echo $BACKEND_URL
#BACKEND="\"$BACKEND_URL\""
#sed -i \
#    "s#window\.backendUrl[ ]*=[^\<]*#window.backendUrl=${BACKEND}#" \
#    /usr/local/apache2/htdocs/index.html

## Execute CMD
$@
