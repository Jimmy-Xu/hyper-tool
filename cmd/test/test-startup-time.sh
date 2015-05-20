#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh


if [ $# -eq 1 -a "$1" == "2" ]
then
	TIME_TYPE="(internal time)"
else
	TIME_TYPE="(system time)"
fi


show_message "test pod startup time ${TIME_TYPE}" green bold

#check hyper dir
is_hyper_exist

#check hyperd process
is_hyperd_running


echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}number${PURPLE} of pod(s)${RESET}(press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	if [[ $CHOICE =~ ^[[:digit:]]+$ ]] && [[ ${CHOICE} -ge 1 ]]
	then
		CNT=$CHOICE

		LOG_DIR=${BASE_DIR}/../../log/startup/
		LOG_FILE=${LOG_DIR}/time-startup-$(date +'%s').log
		#ensure log dir
		mkdir -p ${LOG_DIR}

		cd "${GOPATH}/src/${HYPER_CLONE_DIR}"
		if [ -f "${LOG_FILE}" ]
		then
			show_message "delete old log [ ${LOG_FILE} ]" yellow bold
			\rm -rf "${LOG_FILE}"
		fi

		BEFORE=`sudo ./hyper list pod | grep "pod-.*running" | wc -l`

		show_message "start create ${WHITE}${CHOICE}${GREEN} pod(s)..." green bold
		for i in `seq 1 $CNT`
		do
		  echo -n "No. $i "`date +"%F %T" `
		  START_TS=$(date +'%s')
		  (time sudo ./hyper pod test/ubuntu.pod) >>"${LOG_FILE}" 2>&1
		  END_TS=$(date +'%s')
		  echo "( ${GREEN}$((END_TS-START_TS)) ${RESET}seconds )"
		done

		AFTER=`sudo ./hyper  list pod | grep "pod-.*running" | wc -l`

		echo
		echo "CREATED POD(S)  : ${GREEN}${CNT}${RESET}"
		echo "ORIG running    : ${GREEN}${BEFORE}${RESET}"
		echo "CURRENT running : ${GREEN}${AFTER}${RESET}"

		show_message "startup time stat (ms):" yellow bold
		echo "========================="
		echo -e "min\tmax\tavg"
		echo "-------------------------"

		if [ $# -eq 1 -a "$1" == "2" ]
		then
			#stat by internal time
			STAT_RLT=$(grep  -B1 "VM is successful to run"  ${LOG_FILE}  | grep "^Time to" | awk '{print $7}' \
				| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){avg=total/count}else{avg=""}; printf "%s\t%s\t%s",min,max,avg}')
		else
			#stat by system time
			STAT_RLT=$(grep  -A2 "VM is successful to run" ${LOG_FILE} | grep real | cut -d"m" -f2 | cut -d"s" -f1 \
				| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%s\t%s\t%s",min*1000,max*1000,total/count*1000}else{print ""}; }')
		fi


		echo "${GREEN}${STAT_RLT}${RESET}"
		echo "========================="
		echo "${TIME_TYPE}"

	else
		show_message "please input a number, [ $CHOICE ] isn't a valid number(>=1)" red bold
	fi
fi


show_message "Done." green bold
