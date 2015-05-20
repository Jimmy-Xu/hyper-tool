#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "start docker" green bold

#check if docker is installed
is_docker_installed

show_message "start docker now" green bold
sudo service docker start

show_message "Done." green bold
