#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

LIST_OBJ="pod"
if [ $# -eq 1 ]
then
	VALID_OBJ=(vm pod container)

	if echo "${VALID_OBJ[@]}" | grep -w "$1" &>/dev/null
	then
		#valid object
		LIST_OBJ=$1
	else
		#invalid object
		echo "list object include [ ${VALID_OBJ[@]} ], [ $1 ] is an invalid object, will list pod"
	fi
fi


show_message "start list '${LIST_OBJ}'" green bold

#check hyper dir
is_hyper_exist


cd "$GOPATH/src/${HYPER_CLONE_DIR}"
echo -e "\nrun command line: [ ${BOLD}${PURPLE}sudo ./hyper list ${LIST_OBJ} ${RESET} ]"
echo -e "\n${BOLD}${YELLOW}===================================================="
echo " Here are all ${WHITE}${LIST_OBJ}${YELLOW}(s):"
echo "====================================================${RESET}"
sudo ./hyper list ${LIST_OBJ}

show_message "Done." green bold