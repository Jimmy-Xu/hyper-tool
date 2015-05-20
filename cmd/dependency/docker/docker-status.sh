#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "show docker status" green

#check if docker is installed
is_docker_installed

show_message "current docker status" purple
sudo service docker status

show_message "Done." green
