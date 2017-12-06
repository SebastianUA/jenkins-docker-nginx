#!/bin/bash -x

# CREATED:
# vitaliy.natarov@yahoo.com
#
# Unix/Linux blog:
# http://linux-notes.org
# Vitaliy Natarov
#

if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] ; then
    echo "RedHat or CentOS";
    Redhat-lsb-core="rpm -qa | grep redhat-lsb-core"
	if [ ! -n "`$Redhat-lsb-core`"]; then 
		yum install redhat-lsb-core -y 
	fi
    #
    OS=$(lsb_release -ds|cut -d '"' -f2|awk '{print $1}')
    OS_MAJOR_VERSION=`sed -rn 's/.*([0-9])\.[0-9].*/\1/p' /etc/redhat-release`
	OS_MINOR_VERSION=`sed -rn 's/.*[0-9].([0-9]).*/\1/p' /etc/redhat-release`
	Bit_OS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
	#
	$SETCOLOR_GREEN
	echo "$OS-$OS_MAJOR_VERSION.$OS_MINOR_VERSION with $Bit_OS bit arch"
	$SETCOLOR_NORMAL
	#
	# install some utilites
	if ! type -path "wget" > /dev/null 2>&1; then yum install wget -y; else echo "wget INSTALLED"; fi
	if ! type -path "git" > /dev/null 2>&1; then yum install git -y; else echo "git INSTALLED"; fi
	#
	if ! type -path "docker" > /dev/null 2>&1; then
		yum install -y yum-utils makecache fast
		yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		yum -y install docker-ce
		service docker restart
	else echo "docker INSTALLED"; 
	fi	
	curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/usr/local/src/docker-machine && chmod +x /usr/local/src/docker-machine && sudo mv /tmp/docker-machine /usr/local/bin/docker-machine

elif [ -f /etc/fedora_version ]; then
	 echo "Fedora";
	 #
	 OS=$(lsb_release -ds|cut -d '"' -f2|awk '{print $1}')
     OS_MAJOR_VERSION=`sed -rn 's/.*([0-9])\.[0-9].*/\1/p' /etc/fedora_version`
	 OS_MINOR_VERSION=`sed -rn 's/.*[0-9].([0-9]).*/\1/p' /etc/fedora_version`
	 Bit_OS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/') 
	 #
	 $SETCOLOR_GREEN
	 echo "$OS-$OS_MAJOR_VERSION.$OS_MINOR_VERSION($CODENAME) with $Bit_OS bit arch"
	 $SETCOLOR_NORMAL
	 # 
elif [ -f /etc/debian_version ]; then
    echo "Debian/Ubuntu/Kali Linux";
    #
    OS=$(lsb_release -ds|cut -d '"' -f2|awk '{print $1}')
    OS_MAJOR_VERSION=`sed -rn 's/.*([0-9])\.[0-9].*/\1/p' /etc/debian_version`
	OS_MINOR_VERSION=`sed -rn 's/.*[0-9].([0-9]).*/\1/p' /etc/debian_version`
	Bit_OS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
    #
	CODENAME=`cat /etc/*-release | grep "VERSION="`
	CODENAME=${CODENAME##*\(}
	CODENAME=${CODENAME%%\)*}
	#
	$SETCOLOR_GREEN
	echo "$OS-$OS_MAJOR_VERSION.$OS_MINOR_VERSION($CODENAME) with $Bit_OS bit arch"
	$SETCOLOR_NORMAL
	#
	# install some utilites
	if ! type -path "wget" > /dev/null 2>&1; then apt-get install wget -y; else echo "wget INSTALLED"; fi
	if ! type -path "git" > /dev/null 2>&1; then apt-get install git -y; else echo "git INSTALLED"; fi
	#
	if ! type -path "docker" > /dev/null 2>&1; then
		cd /usr/local/src && wget -qO- https://get.docker.com/ | sh
		#usermod -aG docker your-user
		service docker restart
	else echo "docker INSTALLED"; 
	fi
	curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && mv /tmp/docker-machine /usr/local/bin/docker-machine	
elif [ -f /usr/sbin/system_profiler ]; then
	echo "MacOS!";
	#
	OS=$(uname)
	Mac_Ver=$(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}')
	Bit_OS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
	#
	$SETCOLOR_GREEN
	echo "$OS-$Mac_Ver with $Bit_OS bit arch"
	$SETCOLOR_NORMAL
	#
else
    OS=$(uname -s)
    VER=$(uname -r)
    echo 'OS=' $OS 'VER=' $VER
fi