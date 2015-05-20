#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "show hyperinit repo info" green

#main
show_hyperinit_info

show_message "Done." green
