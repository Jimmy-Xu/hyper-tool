#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "pulling ${HYPERINIT_CLONE_DIR} repo..." green

#check if hyperinit already exist
is_hyperinit_exist

#main
cd "$GOPATH/src/${HYPERINIT_CLONE_DIR}"
git pull

if [ $? -eq 0 ]
then
	#show local repo info
	show_hyperinit_info
else
	echo "pull hyperinit repo failed!"
fi

show_message "Done." green