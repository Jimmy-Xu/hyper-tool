#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "show qemu version" green

#check if go is installed
is_qemu_installed

show_message "Done." green
