#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "stop docker" green

#check if docker is installed
is_docker_installed

show_message "stop docker now" purple
sudo service docker stop

show_message "Done." green
