#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "pulling hyper repo..." green bold

#check GOPATH
is_gopath_exist


#check if hyper already exist
is_hyper_exist

#main
cd "$GOPATH/src/${HYPER_CLONE_DIR}"
git pull

if [ $? -eq 0 ]
then
	#show local repo info
	show_hyper_info
else
	echo "pull hyper repo failed!"
fi

show_message "Done." green bold