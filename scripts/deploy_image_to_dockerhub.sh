#!/bin/bash -x

# CREATED:
# vitaliy.natarov@yahoo.com
#
# Unix/Linux blog:
# http://linux-notes.org
# Vitaliy Natarov
#
function Install_Software () {
      #
      if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] || [ -f /etc/fedora_version ] ; then
            if ! type -path "expect" > /dev/null 2>&1; then
                  yum install expect -y &> /dev/null
            fi
            elif [ -f /etc/debian_version ]; then
                  echo "Debian/Ubuntu/Kali Linux";
                  #
                  if ! type -path "expect" > /dev/null 2>&1; then
                        aptitude install expect-dev expect -y &> /dev/null
                  fi
            else
                  OS=$(uname -s)
                  VER=$(uname -r)
                  echo 'OS=' $OS 'VER=' $VER
      fi
} 
#

#export DOCKER_ID_USER="DOCKER_ID_USER"
#DOCKER_USER_PASSWD="XXXXXXXXXXXXX"

while getopts "u:p:h" opt
do
  case $opt in
    u) export DOCKER_ID_USER=$(echo $OPTARG)  
       ;;
    p) DOCKER_USER_PASSWD=$(echo $OPTARG)
       ;; 
    h) echo "Use: -u for DOCKER_ID_USER; -p to set password for DOCKER_ID_USER; default: without any parameters";;    
    *) echo "Use: -u for DOCKER_ID_USER; -p to set password for DOCKER_ID_USER; default: without any parameters";;  
  esac
done;

if [ ! -n "$2" ]; then
  echo "Please use -u parameter to set DOCKER_ID_USER";
  exit;
elif [ ! -n "$4" ]; then
  echo "Please use -p parameter to set password for DOCKER_ID_USER";
  exit;
fi    

# start this funcion
Install_Software

expect <<EOF 
	spawn docker login -u $DOCKER_ID_USER
    expect "Password:"
    send "$DOCKER_USER_PASSWD\n"
    sleep 3
    expect "Login Succeeded"
    send "\n"

EOF

LATEST_TAG=$(wget -q https://registry.hub.docker.com/v1/repositories/captainua/nginx_lua/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'| grep -Ev "^$" | tail -n1)
CUT_TAG_NUMBER=$(echo $LATEST_TAG | cut -c8- | cut -d"." -f1)
NEXT_TAG=$(($CUT_TAG_NUMBER + 1)) 

docker tag centos7/nginx_lua $DOCKER_ID_USER/nginx_lua:version$NEXT_TAG.0
docker push $DOCKER_ID_USER/nginx_lua:version$NEXT_TAG.0
docker logout

echo "Done!"
