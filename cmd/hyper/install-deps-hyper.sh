#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "install dependency for hyper" green

#check GOROOT and go
is_go_exist


#check if hyper already exist
is_hyper_exist

#main
if [ -d $GOPATH/src/golang.org/x ];then
	\rm $GOPATH/src/golang.org/x -rf
fi
mkdir -p $GOPATH/src/golang.org/x

show_message "clone tools..." green
git clone https://github.com/golang/tools $GOPATH/src/golang.org/x/tools

show_message "go get godep..." green
go get github.com/tools/godep

if [ $? -eq 0 ];then
	show_message "instal deps succeed!" green
else
	show_message "instal deps failed!" red
fi


show_message "Done." green
