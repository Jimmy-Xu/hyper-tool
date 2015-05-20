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


echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}number${PURPLE} of pod(s)${RESET}(>=1,press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	if [[ $CHOICE =~ ^[[:digit:]]+$ ]] && [[ ${CHOICE} -ge 1 ]]
	then
		cd "${GOPATH}/src/${HYPER_CLONE_DIR}"

		LOG_DIR=${BASE_DIR}/../../log/replace
		#ensure log dir
		mkdir -p ${LOG_DIR}

		LOG_TS=$(date +'%s')
		LOG_FILE=${LOG_DIR}/time-replace-${LOG_TS}.log
		LOG_FILE_RUNNING=${LOG_DIR}/pod-running-${LOG_TS}.log
		LOG_FILE_CREATED=${LOG_DIR}/pod-created-${LOG_TS}.log


		CNT=$CHOICE
		#create running pod(s)
		BEFORE=`sudo ./hyper list pod | grep "pod-.*running" | wc -l`
		show_message "[Step 1] create ${WHITE}${CHOICE}${GREEN} ${BLUE}running${GREEN} pod(s)..." green bold
		for i in `seq 1 $CNT`
		 do
		   echo -n "No. $i "`date +"%F %T" `
		   START_TS=$(date +'%s')
		   (time sudo ./hyper pod test/ubuntu.pod) >>"${LOG_FILE_RUNNING}" 2>&1
		   END_TS=$(date +'%s')
		   echo "( ${GREEN}$((END_TS-START_TS)) ${RESET}seconds )"
		done
		AFTER=`sudo ./hyper  list pod | grep "pod-.*running" | wc -l`
		echo "STARTED POD(S)  : ${GREEN}${CNT}${RESET}"
		echo "ORIG running    : ${GREEN}${BEFORE}${RESET}"
		echo "CURRENT running : ${GREEN}${AFTER}${RESET}"

		#create created pod(s)
		BEFORE=`sudo ./hyper list pod | grep "pod-.*created" | wc -l`
		show_message "[Step 2] create ${WHITE}${CHOICE}${GREEN} ${YELLOW}created${GREEN} pod(s)..." green bold
		for i in `seq 1 $CNT`
		 do
		   echo -n "No. $i "`date +"%F %T" `
		   START_TS=$(date +'%s')
		   (time sudo ./hyper create test/ubuntu.pod) >>"${LOG_FILE_CREATED}" 2>&1
		   END_TS=$(date +'%s')
		   echo "( ${GREEN}$((END_TS-START_TS)) ${RESET}seconds )"
		done
		AFTER=`sudo ./hyper  list pod | grep "pod-.*created" | wc -l`
		echo "CREATED POD(S)  : ${GREEN}${CNT}${RESET}"
		echo "ORIG created    : ${GREEN}${BEFORE}${RESET}"
		echo "CURRENT created : ${GREEN}${AFTER}${RESET}"

		#test replace
		show_message "[Step 3] tets replace pod(s)..." green bold


		OLD_IFS="$IFS" #save current IFS
		IFS=$'\x0A' #enter key
		POD_OLD=($(grep " pod-.*" ${LOG_FILE_RUNNING} | awk '{print $4}'))
		POD_NEW=($(grep " pod-.*" ${LOG_FILE_CREATED} | awk '{print $4}'))
		IFS=${OLD_IFS}

		echo "${WHITE}number of old pod(${BLUE}running${WHITE}) ${GREEN}: ${#POD_OLD[@]} ${RESET}"
		echo "${WHITE}number of new pod(${YELLOW}created${WHITE}) ${GREEN}: ${#POD_NEW[@]} ${RESET}"

		if [ ${#POD_OLD[@]} -eq ${#POD_NEW[@]} ]
		then
			#number of old pod is same as new pod
			show_message "start replace..." green bold

		else
			show_message "number of old pod is different with new pod, can not replace" red bold
		fi


	else
		show_message "please input a number, [ $CHOICE ] isn't a valid number(>=1)" red bold
	fi
fi


show_message "Done." green bold
