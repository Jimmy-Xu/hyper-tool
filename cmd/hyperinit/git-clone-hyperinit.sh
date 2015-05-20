#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "clone hyperinit repo" green


if [ ! -d "$GOPATH/src" ]
then
  mkdir -p "$GOPATH/src"
fi
#enter "$GOPATH/src"
cd "$GOPATH/src"


#process clone
TARGET_DIR="$GOPATH/src/${HYPERINIT_CLONE_DIR}"
if [ -d "${TARGET_DIR}" ]
then
	#prompt overwrite or not?
	echo -e -n "\n${BLUE}${TARGET_DIR} ${BOLD}${PURPLE}already exist!${RESET} Will you re-clone the hyperinit repo?(y/N)"
	read -n2 CHOICE
fi

if [[ ! -d "${TARGET_DIR}" ]] || [[ "${CHOICE}" == "y" ]]
then
	#clone or re-clone

	#remove old dir
	if [ -d "${TARGET_DIR}" ]
	then
		show_message "delete old repo dir ${BLUE}${TARGET_DIR}${GREEN}" green
		rm ${TARGET_DIR} -rf
	fi

	show_message "start clone ${BLUE}<${HYPERINIT_REPO}> ${GREEN}to ${BLUE}<${TARGET_DIR}>${RESET}" green
	echo "--------------------------------------------"
	git clone ${HYPERINIT_REPO} ${HYPERINIT_CLONE_DIR}
	echo "--------------------------------------------"
	if [ $? -eq 0 ]
	then
		#show local repo info after clone succeed
		show_hyperinit_info
	else
		show_message "Clone Failed!" yellow bold
	fi
else
	show_message "Clone Canceled!" yellow bold
fi

show_message "Done." green