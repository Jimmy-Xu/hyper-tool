#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "add user to docker group" green bold

#check if docker is installed
is_docker_installed

echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}username#{PURPLE} to add to docker group${RESET} (just press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	sudo usermod -aG docker ${CHOICE}
	if [ $? -eq 0 ]
	then
		echo -e "\nadd user ${CHOICE} to docker group succeed:)\n"
	else
		echo -e "\nadd user ${CHOICE} to docker group failed:(\n"
	fi
fi

echo -e "\n${BOLD}${YELLOW}====================================="
echo "> all users in docker group"
echo "=====================================${RESET}"
grep "^docker"  /etc/group | cut -d":" -f4
echo

show_message "Done." green bold
