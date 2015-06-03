#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "install dependency for hyperinit" green

#check if hyper already exist
is_hyperinit_exist

#main
cd "$GOPATH/src/${HYPERINIT_CLONE_DIR}"
which apt-get >/dev/null 2>&1
if [ $? -eq 0 ];then
	sudo apt-get install -y autoconf automake
else
	sudo yum install -y autoconf automake
fi

show_message "Done." green
