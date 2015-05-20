#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "install docker" green

OS_DISTRO=$(get_os_distro)
echo -e "OS_DISTRO : ${OS_DISTRO}\n"

#check docker version
INST_DOCKER=$(which docker 2>/dev/null)
if [ $? -eq 0 ]
then
	docker --version
	ACTION="upgrade"
else
	echo "docker hasn't been installed"
	ACTION="install"
fi


#install docker under ubuntu
if [ "${OS_DISTRO}" == "Ubuntu" ]
then
	if [ "${ACTION}" == "install" ]
	then
		echo "install docker..."
		sudo wget -qO- https://get.docker.com/ | bash
	elif [ "${ACTION}" == "upgrade" ]
	then
		echo "upgrade docker..."
		sudo wget -N https://get.docker.com/ | bash
	fi
fi

show_message "Done." green
