#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

if [ $# -eq 1 ]
then
	if [ "$1" == "-v=3" ]
	then
		show_message "starting hyperd with v3" green bold
		MODE=$1
	else
		show_message " [$1] is not invalid parameter, starting hyperd normal" yellow bold
		MODE=""
	fi
else
	show_message "starting hyperd normal" green bold
	MODE=""
fi


#check if hyper already exist
is_hyper_exist

DAEMON_DIR="$GOPATH/src/${HYPER_CLONE_DIR}"
CONFIG_DIR="${BASE_DIR}/../../../etc/config"

echo -e "\n---------------------------------------------------"
echo "${YELLOW}daemon file: [ ${PURPLE}${DAEMON_DIR}/hyperd${YELLOW} ]${RESET}"
ls -l --color "${DAEMON_DIR}/hyperd" 2>/dev/null

echo -e "\n---------------------------------------------------"
echo "${YELLOW}config file: [ ${PURPLE}${CONFIG_DIR}${YELLOW} ]${RESET}"
ls -l --color "${CONFIG_DIR}" 2>/dev/null

#check hyperd
if [ -f "${DAEMON_DIR}/hyperd" ]
then
	cd "${DAEMON_DIR}"
	echo -e "\ncurrent Dir: [ ${BLUE}"`pwd`"${RESET} ]"
	#check config
	if [ -f "${CONFIG_DIR}" ]
	then
		echo -e "\n${GREEN}start hyperd command line: \n ${BOLD}${YELLOW}sudo ./hyperd ${MODE} --config=${CONFIG_DIR}${GREEN} ${RESET}\n"
		echo "${MODE}"
		if [ "${MODE}" == "-v=3" ]
		then
			sudo ./hyperd -v=3 --config=${CONFIG_DIR}
		else
			sudo ./hyperd --config=${CONFIG_DIR}
		fi
	else
		echo "${RED}can not find config [ ${PURPLE}${CONFIG_DIR}${RED} ]${RESET}, cancel!"
	fi
else
	echo "${RED}[ ${PURPLE}${DAEMON_DIR}/hyperd${RED} ] not exist!${RESET}"
fi


show_message "Done." green bold