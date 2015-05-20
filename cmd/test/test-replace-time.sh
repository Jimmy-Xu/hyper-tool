#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh


# if [ $# -eq 1 -a "$1" == "2" ]
# then
# 	TIME_TYPE="(internal time)"
# else
# 	TIME_TYPE="(system time)"
# fi


show_message "test pod replace time ${TIME_TYPE}" green bold

#check hyper dir
is_hyper_exist

#check hyperd process
is_hyperd_running


echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}number${PURPLE} of pod(s)${RESET}(press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	if [[ $CHOICE =~ ^[[:digit:]]+$ ]]
	then
		cd "${GOPATH}/src/${HYPER_CLONE_DIR}"

		LOG_DIR=${BASE_DIR}/../../log
		LOG_FILE=${LOG_DIR}/time-replace-$(date +'%s').log
		#ensure log dir
		mkdir -p ${LOG_DIR}

		CNT=$CHOICE
		#create running pod(s)
		BEFORE=`sudo ./hyper list pod | grep "pod-.*running" | wc -l`
		show_message "[Step 1] create ${WHITE}${CHOICE}${GREEN} ${BLUE}running${GREEN} pod(s)..." green bold
		for i in `seq 1 $CNT`
		 do
		   echo -n "No. $i "`date +"%F %T" `
		   START_TS=$(date +'%s')
		   (time sudo ./hyper pod test/ubuntu.pod) >>"${LOG_FILE}" 2>&1
		   END_TS=$(date +'%s')
		   echo "( ${GREEN}$((END_TS-START_TS)) ${RESET}seconds )"
		done
		AFTER=`sudo ./hyper  list pod | grep "pod-.*running" | wc -l`
		echo "STARTED POD(S)  : ${GREEN}${CNT}${RESET}"
		echo "ORIG running    : ${GREEN}${BEFORE}${RESET}"
		echo "CURRENT running : ${GREEN}${AFTER}${RESET}"

		#create stopped pod(s)
		BEFORE=`sudo ./hyper list pod | grep "pod-.*created" | wc -l`
		show_message "[Step 2] create ${WHITE}${CHOICE}${GREEN} ${BLUE}stopped${GREEN} pod(s)..." green bold
		for i in `seq 1 $CNT`
		 do
		   echo -n "No. $i "`date +"%F %T" `
		   START_TS=$(date +'%s')
		   (time sudo ./hyper create test/ubuntu.pod) >>"${LOG_FILE}" 2>&1
		   END_TS=$(date +'%s')
		   echo "( ${GREEN}$((END_TS-START_TS)) ${RESET}seconds )"
		done
		AFTER=`sudo ./hyper  list pod | grep "pod-.*created" | wc -l`
		echo "CREATED POD(S)  : ${GREEN}${CNT}${RESET}"
		echo "ORIG stopped    : ${GREEN}${BEFORE}${RESET}"
		echo "CURRENT stopped : ${GREEN}${AFTER}${RESET}"

		#test replace
		show_message "[Step 3] tets replace pod(s)..." green bold


	else
		show_message "please input a number, [ $CHOICE ] isn't a number" red bold
	fi
fi
