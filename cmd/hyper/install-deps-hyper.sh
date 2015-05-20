#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "install dependency for hyper" green

#check GOROOT and go
is_go_exist


#check if hyper already exist
is_hyper_exist

#main
cd "$GOPATH/src/${HYPER_CLONE_DIR}"
if [ -f ./make_deps.sh ]
then
	./make_deps.sh
fi

show_message "Done." green
