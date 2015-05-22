#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "modify memory in pod json" green

#check hyper dir
is_hyper_exist

cd "$GOPATH/src/${HYPER_CLONE_DIR}"

show_message "list test pod" green
echo -e "${BOLD}${CYAN}===================================================="
echo " Here are all pod(s) for test :"
echo "====================================================${RESET}"
ls -l --color test/*.pod


echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}pod json filename${PURPLE} to modify${RESET}(example: ${YELLOW}ubuntu${RESET}, or press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	POD_PATH="test/${CHOICE}.pod"
	if [ -f "${POD_PATH}" ]
	then
		echo -e "${BOLD}${YELLOW}===================================================="
		echo " Here is content of ${POD_PATH} before modify:"
		echo "====================================================${RESET}"
		cat "${POD_PATH}" | ${BASE_DIR}/../../util/jq '.'
		echo -e "${BOLD}${YELLOW}====================================================${RESET}"

		echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}memory size${PURPLE}(MB)${RESET}(>=1,press 'Enter' to cancel):"
		read CHOICE

		if [ ! -z ${CHOICE} ]
		then
			if [[ $CHOICE =~ ^[[:digit:]]+$ ]] && [[ ${CHOICE} -ge 1 ]]
			then
				show_message "update memory in ${POD_PATH}" green
				cat "${POD_PATH}" | jq ".resource.memory=${CHOICE}" > "${POD_PATH}".tmp
				rm  "${POD_PATH}"
				mv  "${POD_PATH}".tmp  "${POD_PATH}"

				echo -e "${BOLD}${YELLOW}===================================================="
				echo " Here is content of ${POD_PATH} after modify:"
				echo "====================================================${RESET}"
				cat "${POD_PATH}" | ${BASE_DIR}/../../util/jq '.'
				echo -e "${BOLD}${YELLOW}====================================================${RESET}"
			else
				show_message "please input a number, [ $CHOICE ] isn't a valid memory size(>=1)" red bold
			fi
		else
			show_message "modify pod memory canceled!" yellow bold
		fi
	else
		show_message "pod file not found ${POD_PATH}, cancel!" red bold
	fi
else
	show_message "modify pod memory canceled!" yellow bold
fi

show_message "Done." green