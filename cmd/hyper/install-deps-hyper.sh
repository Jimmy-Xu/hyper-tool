#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "install dependency for hyper" green

#check GOROOT and go
is_go_exist


#check if hyper already exist
is_hyper_exist

#main
cd ${GOPATH}/src/${HYPER_CLONE_DIR}
if [ -f make_deps.sh ];then
	show_message "found make_deps.sh, execute now..." green
	DEPS_DIR=($(cat make_deps.sh  | grep clone | awk '{print $4}' | cut -d"/" -f4 | sort -u ))
	for (( i = 0 ; i < ${#DEPS_DIR[@]} ; i++ ))
	do
		item=${DEPS_DIR[$i]}
		if [ -d ${GOPATH}/src/github.com/${item} ];then
			\rm -rf ${GOPATH}/src/github.com/${item}
		fi
	done
	. ./make_deps.sh
else
	show_message "install deps with godep..." green
	if [ -d $GOPATH/src/golang.org/x ];then
		\rm $GOPATH/src/golang.org/x -rf
	fi
	mkdir -p $GOPATH/src/golang.org/x

	show_message "clone tools..." green
	git clone https://github.com/golang/tools $GOPATH/src/golang.org/x/tools

	show_message "go get godep..." green
	go get github.com/tools/godep
fi

if [ $? -eq 0 ];then
	show_message "instal deps succeed!" green
else
	show_message "instal deps failed!" red
fi


show_message "Done." green
