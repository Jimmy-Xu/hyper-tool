#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "start docker" green

#check if docker is installed
is_docker_installed

show_message "start docker now" purple
sudo service docker start

show_message "Done." green
