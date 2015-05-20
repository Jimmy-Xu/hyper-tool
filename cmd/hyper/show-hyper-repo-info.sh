#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "show hyper repo info" green bold

#check GOPATH
is_gopath_exist


#main
show_hyper_info

show_message "Done." green bold
