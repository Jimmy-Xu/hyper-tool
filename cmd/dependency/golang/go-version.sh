#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "show go version" green bold

#check if go is installed
is_golang_installed

show_message "Done." green bold
