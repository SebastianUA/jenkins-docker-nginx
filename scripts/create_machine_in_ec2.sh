#!/bin/bash -x

# CREATED:
# vitaliy.natarov@yahoo.com
#
# Unix/Linux blog:
# http://linux-notes.org
# Vitaliy Natarov
#
# export DOCKER_ID_USER="docker_user"
# export ACCESS_KEY="XXXXXXXXXX"
# export SECRET_KEY="YYYYYYYYYY"
while getopts "u:a:s:h" opt
do
	case $opt in
		u) export DOCKER_ID_USER=$(echo $OPTARG)	
		   ;;
		a) export ACCESS_KEY=$(echo $OPTARG)
		   ;;
		s) export SECRET_KEY=$(echo $OPTARG)
		   ;;   
		h) echo "Use: -u for DOCKER_ID_USER; -a for ACCESS_KEY; -s for SECRET_KEY; default: without any parameters";;	   
		*) echo "Use: -u for DOCKER_ID_USER; -a for ACCESS_KEY; -s for SECRET_KEY; default: without any parameters";; 
	esac
done;

if [ ! -n "$2" ]; then
	echo "Please use -u parameter to set DOCKER_ID_USER";
	exit;
elif [ ! -n "$4" ]; then
	echo "Please use -a parameter to set ACCESS_KEY";
	exit;
elif [ ! -n "$6" ]; then
	echo "Please use -s parameter to set SECRET_KEY";
	exit;
fi		

LATEST_TAG=$(wget -q https://registry.hub.docker.com/v1/repositories/captainua/nginx_lua/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'| grep -Ev "^$" | tail -n1)
CUT_TAG_NUMBER=$(echo $LATEST_TAG | cut -c8- | cut -d"." -f1)
CURRENT_TAG=$(($CUT_TAG_NUMBER))

docker-machine create --driver amazonec2 --amazonec2-access-key $ACCESS_KEY --amazonec2-secret-key $SECRET_KEY --amazonec2-region us-east-1 --amazonec2-open-port 80 --amazonec2-open-port 443 --amazonec2-vpc-id vpc-3cdc1145 nginx-lua-version$CURRENT_TAG.0    
docker-machine restart nginx-lua-version$CURRENT_TAG.0
docker-machine ssh nginx-lua-version$CURRENT_TAG.0
docker pull $DOCKER_ID_USER/nginx_lua:version$CURRENT_TAG.0
sudo docker run -d -p 80:80 -p 443:443 $DOCKER_ID_USER/nginx_lua:version$CURRENT_TAG.0
exit
echo "Done!"
