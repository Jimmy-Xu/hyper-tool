#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "checkout branch of hyperinit" green bold

#main
show_hyperinit_info

echo -e -n "\n${BOLD}${PURPLE}Please input the branch name${RESET}( just press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	cd "${GOPATH}/src/${HYPERINIT_CLONE_DIR}"
	git checkout $CHOICE
	if [ $? -eq 0 ]
	then
		echo -e "\ncheck out branch to ${CHOICE} successfully:)\n"
		#show local repo info after checkout branch succeed
		show_hyperinit_info
	else
		echo -e "\ncheck out branch to ${CHOICE} unsuccessfully:(\n"
	fi
else
	echo -e "\ncheck out branch canceled\n"
fi

show_message "Done." green bold