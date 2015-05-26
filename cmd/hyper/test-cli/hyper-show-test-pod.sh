#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "start pod" green

#check hyper dir
is_hyper_exist

#check hyperd process
is_hyperd_running

cd "$GOPATH/src/${HYPER_CLONE_DIR}"

show_message "list test pod" green
echo -e "${BOLD}${CYAN}===================================================="
echo " Here are all pod(s) for test :"
echo "====================================================${RESET}"
ls -l --color examples/*.pod


echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}pod json filename${PURPLE}${RESET}(example: ${YELLOW}ubuntu${RESET}, or press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	POD_PATH="examples/${CHOICE}.pod"
	if [ -f "${POD_PATH}" ]
	then
		echo -e "${BOLD}${YELLOW}===================================================="
		echo " Here is content of ${POD_PATH}:"
		echo "====================================================${RESET}"
		cat "${POD_PATH}" | ${BASE_DIR}/../../../util/jq '.'
		echo -e "${BOLD}${YELLOW}====================================================${RESET}"
	else
		show_message "pod file not found ${POD_PATH}, cancel!" red bold
	fi
else
	show_message "start pod canceled!" yellow bold
fi

show_message "Done." green