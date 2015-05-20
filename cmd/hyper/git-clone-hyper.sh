#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "clone hyper repo" green

#check GOPATH
is_gopath_exist


if [ ! -d "$GOPATH/src" ]
then
  mkdir -p "$GOPATH/src"
fi
#enter "$GOPATH/src"
cd "$GOPATH/src"


#process clone
TARGET_DIR="$GOPATH/src/${HYPER_CLONE_DIR}"
if [ -d "${TARGET_DIR}" ]
then
	#prompt overwrite or not?
	echo -e -n "\n${BOLD}${PURPLE}${TARGET_DIR} already exist!${RESET} Will you re-clone the hyper repo?(y/N)"
	read -n2 CHOICE
fi

if [[ ! -d "${TARGET_DIR}" ]] || [[ "${CHOICE}" == "y" ]]
then
	#clone or re-clone

	#remove old dir
	if [ -d "${TARGET_DIR}" ]
	then
		show_message "delete old repo dir: ${BLUE}${TARGET_DIR}${GREEN}" green
		rm ${TARGET_DIR} -rf
	fi

	show_message "start clone ${BLUE}<${HYPER_REPO}> ${WHITE}to ${BLUE}<${TARGET_DIR}>${RESET}" green
	echo "--------------------------------------------"
	git clone ${HYPER_REPO} ${HYPER_CLONE_DIR}
	if [ $? -eq 0 ]
	then
		#show local repo info after clone succeed
		show_message "clone hyper repo succeed!" green bold
		show_hyper_info
	else
		show_message "clone hyper repo failed!" red bold
	fi
else
	show_message "clone hyper repo canceled!" yellow bold
fi

show_message "Done." green