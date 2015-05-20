#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh


echo -e -n "\n${BOLD}${PURPLE}Please choice ${WHITE}time type${PURPLE}${RESET}('i' for internal, other or 'Enter' for system time):"
read CHOICE

TIME_TYPE="(system time)"
if [ ! -z ${CHOICE} ]
then
	if [ "${CHOICE}" == "i" ]
	then
		TIME_TYPE="(internal time)"
	fi
fi

show_message "measure pod startup time ${WHITE}${TIME_TYPE}${RESET}" green

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
			touch "${LOG_FILE}"
		fi

		BEFORE=`sudo ./hyper list pod | grep "pod-.*running" | wc -l`

		show_message "start create ${WHITE}${CHOICE}${GREEN} pod(s)..." green
		for i in `seq 1 $CNT`
		do
		  echo -n "No. $i "`date +"%F %T" `
		  START_TS=$(date +'%s')
		  (time sudo ./hyper pod test/ubuntu.pod) >>"${LOG_FILE}" 2>&1
		  END_TS=$(date +'%s')
		  echo "( ${PURPLE}$((END_TS-START_TS)) ${RESET}seconds )"
		done

		AFTER=`sudo ./hyper  list pod | grep "pod-.*running" | wc -l`

		echo
		echo "CREATED POD(S)  : ${PURPLE}${CNT}${RESET}"
		echo "ORIG running    : ${PURPLE}${BEFORE}${RESET}"
		echo "CURRENT running : ${PURPLE}${AFTER}${RESET}"

		show_message "startup time stat (ms):" yellow bold
		echo "========================="
		echo -e "min\tmax\tavg"
		echo "-------------------------"

		if [ "${TIME_TYPE}" == "(system time)" ]
		then
			#stat by system time
			STAT_RLT=$(grep  -A3 "^POD id is pod-" ${LOG_FILE} | grep real | cut -d"m" -f2 | cut -d"s" -f1 \
				| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%s\t%s\t%s",min*1000,max*1000,total/count*1000}else{print ""}; }')
		else
			#stat by internal time
			STAT_RLT=$(grep  -A1 "^POD id is pod-"  ${LOG_FILE}  | grep "^Time to run a POD" | awk '{print $7}' \
				| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){avg=total/count}else{avg=""}; printf "%s\t%s\t%s",min,max,avg}')
		fi

		echo "${PURPLE}${STAT_RLT}${RESET}"
		echo "========================="
		echo "${CYAN}${TIME_TYPE}${RESET}"

	else
		show_message "please input a number, [ $CHOICE ] isn't a valid number(>=1)" red bold
	fi
fi


show_message "Done." green
