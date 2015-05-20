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
echo " Here are all pod(s) to stop :"
echo "====================================================${RESET}"
sudo ./hyper list pod


echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}pod id${PURPLE}${RESET}('$' for all, press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then

	if [ "${CHOICE}" == "$" ]
	then
		show_message "stop all running pod" green bold
		sudo ./hyper list pod | grep "pod-.*running" | awk '{print $1}' | xargs -i sudo ./hyper stop pod {}
	else
		show_message "stop single pod [ ${CHOICE} ]" green bold
		sudo ./hyper stop pod ${CHOICE}
	fi

	#check result
	if [ $? -eq 0 ]
	then
		show_message "stop pod succeed!,show pod list after stop" green bold
		#list pod after stop
		echo -e "\n${BOLD}${YELLOW}===================================================="
		echo " Here are all ${WHITE} pod(s) {YELLOW}(s):"
		echo "====================================================${RESET}"
		sudo ./hyper list pod
	else
		show_message "stop pod failed!" red bold
	fi
else
	show_message "stop pod canceled!" yellow bold
fi

show_message "Done." green bold