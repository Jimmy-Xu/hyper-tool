#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "test pod startup time" green bold

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
		CNT=$CHOICE

		#ensure log dir
		mkdir -p ${BASE_DIR}/../../../log
		LOG_FILE=${BASE_DIR}/../../../log/time-startup.log
		cd "${GOPATH}/src/${HYPER_CLONE_DIR}"
		if [ -f "${LOG_FILE}" ]
		then
			show_message "delete old log [ ${LOG_FILE} ]" yellow bold
			\rm -rf "${LOG_FILE}"
		fi

		BEFORE=`sudo ./hyper list pod | grep running | wc -l`

		show_message "start create ${WHITE}${CHOICE}${GREEN} pod(s)..." green bold
		for i in `seq 1 $CNT`
		do
		  echo -n "No. $i "`date +"%F %T" `
		  START_TS=$(date +'%s')
		  (time sudo ./hyper pod test/ubuntu.pod) >>"${LOG_FILE}" 2>&1
		  END_TS=$(date +'%s')
		  echo "( ${GREEN}$((END_TS-START_TS)) ${RESET}seconds )"
		done

		AFTER=`sudo ./hyper  list pod | grep running | wc -l`

		echo
		echo "CREATED POD(S)  : ${GREEN}${CNT}${RESET}"
		echo "ORIG running    : ${GREEN}${BEFORE}${RESET}"
		echo "CURRENT running : ${GREEN}${AFTER}${RESET}"

		show_message "startup time stat (seconds):" yellow bold
		echo "========================="
		echo -e "min\tmax\tavg"
		echo "-------------------------"
		STAT_RLT=$(grep  -A2 "VM is successful to run" ${LOG_FILE} | grep real | cut -d"m" -f2 | cut -d"s" -f1 \
| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){avg=total/count}else{avg=""}; printf "%s\t%s\t%s",min,max,avg}')
		echo "${GREEN}${STAT_RLT}${RESET}"
		echo "========================="

	else
		show_message "please input a number, [ $CHOICE ] isn't a number" red bold
	fi
fi
