#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "start pod" green bold

#check hyper dir
is_hyper_exist

#check hyperd process
is_hyperd_running


cd "$GOPATH/src/${HYPER_CLONE_DIR}"

show_message "list test pod" green bold
echo -e "${BOLD}${YELLOW}===================================================="
echo " Here are all pod(s) to rm :"
echo "====================================================${RESET}"
sudo ./hyper list pod


echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}pod id${PURPLE}${RESET}('$' for all, press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then

	if [ "${CHOICE}" == "$" ]
	then
		show_message "remove all created pod" green bold
		sudo ./hyper list | grep "pod-.*created" | awk '{print $1}' | xargs -i sudo ./hyper rm {}
	else
		show_message "remove single pod [ ${CHOICE} ]" green bold
		sudo ./hyper pod ${CHOICE}
	fi

	#check result
	if [ $? -eq 0 ]
	then
		show_message "remove pod succeed!,show pod list after rm" green bold
		#list pod after stop
		echo -e "\n${BOLD}${YELLOW}===================================================="
		echo " Here are all ${WHITE} pod(s) {YELLOW}(s):"
		echo "====================================================${RESET}"
		sudo ./hyper list pod
	else
		show_message "remove pod failed!" red bold
	fi
else
	show_message "remove pod canceled!" yellow bold
fi

show_message "Done." green bold