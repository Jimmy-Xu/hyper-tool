#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "install qemu" green

sudo apt-get install qemu

show_message "Done." green
