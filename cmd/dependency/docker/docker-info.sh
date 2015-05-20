#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "show docker info" green bold

#check if docker is installed
is_docker_installed

show_message "show docker info" green bold
sudo docker info
if [ -$? -ne 0 ]
then
	show_message "docker daemon hasn't running now" yellow bold
fi

show_message "Done." green bold
