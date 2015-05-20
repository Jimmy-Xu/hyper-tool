#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "show docker status" green bold

#check if docker is installed
is_docker_installed

show_message "current docker status" green bold
sudo service docker status

show_message "Done." green bold
