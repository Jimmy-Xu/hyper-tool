#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "install go" green

GOLANG_TGZ=${GOLANG}.tar.gz

mkdir -p ${GOROOT_DIR}
cd ${GOROOT_DIR}/..

if [ -f "${GOLANG_TGZ}" ]
then
	#test existed
	show_message "check existed ${GOLANG_TGZ}" green
	is_tar_gz_valid "${GOLANG_TGZ}"
fi

DL_NEW="false"
if [ ! -f "${GOLANG_TGZ}" ]
then
	show_message "download new ${GOLANG_TGZ}" green
	wget ${GOLANG_URL}
	DL_NEW="true"
fi

if [ -f "${GOLANG_TGZ}" ]
then
	if [ "${DL_NEW}" == "true" ]
	then
		show_message "check ${GOLANG_TGZ} again" green
		is_tar_gz_valid "${GOLANG_TGZ}"
	fi

	show_message "start extract ${GOLANG_TGZ}" green
	tar xzf ${GOLANG}.tar.gz
	if [ -$? -eq 0 ]
	then
		show_message "extract ${GOLANG}.tar.gz succeed:)" green
	else
		show_message "extract ${GOLANG}.tar.gz failed:(" red bold
	fi
fi

#check result
if [ ! -z $GOROOT ]
then
	. ~/.bashrc
	show_message "check installed go" purple
	go version

	if [ $? -eq 0 ]
	then
		show_message "install golang succeed:)" green bold
	else
		show_message "install golang failed:(" red bold
	fi
else
	show_message -e "please set GOROOT env first!" yellow bold
fi

show_message "Done." green
