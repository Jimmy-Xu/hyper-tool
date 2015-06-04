#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

#choice time type
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

#choice hyper cli
echo -e -n "\n${BOLD}${PURPLE}Please choice ${WHITE}hyper client${PURPLE}${RESET}('d' for dev version, other or 'Enter' for installer version):"
read CHOICE

HYPER_CLI="hyper"
HYPER_CLI_TYPE="(install version)"
if [ ! -z ${CHOICE} ]
then
	if [ "${CHOICE}" == "d" ]
	then
		HYPER_CLI="./hyper"	
		HYPER_CLI_TYPE="(dev version)"
	fi
fi

if [ "${HYPER_CLI}" == "hyper" ]
then
	is_hyper_cli_installed
fi

show_message "measure pod startup${YELLOW}(parallel)${GREEN} time ${WHITE}${TIME_TYPE}${RESET}" green

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

		LOG_DIR=${BASE_DIR}/../../log/startup
		LOG_FILE=${LOG_DIR}/time-parallel-startup-$(date +'%s').log
		#ensure log dir
		mkdir -p ${LOG_DIR}

		#create link
		LINK_CURRENT=${LOG_DIR}/current
		if [ -f ${LINK_CURRENT} ]
		then
			show_message "log link exist, will remove it first" yellow bold
			rm ${LINK_CURRENT}
		fi
		ln -s ${LOG_FILE} ${LINK_CURRENT}



		cd "${GOPATH}/src/${HYPER_CLONE_DIR}"
		if [ -f "${LOG_FILE}" ]
		then
			show_message "delete old log [ ${LOG_FILE} ]" yellow bold
			\rm -rf "${LOG_FILE}"
			touch "${LOG_FILE}"
		fi

		BEFORE=`sudo ${HYPER_CLI} list pod | grep "pod-.*running" | wc -l`

		show_message "start create ${WHITE}${CHOICE}${GREEN} pod(s)..." green
		for i in `seq 1 $CNT`
		do
		  echo -n "No. $i "`date +"%F %T" `
		  START_TS=$(date +'%s')
		  (time sudo ${HYPER_CLI} pod examples/ubuntu.pod & ) >>"${LOG_FILE}" 2>&1
		  END_TS=$(date +'%s')
		  echo "( ${PURPLE}$((END_TS-START_TS)) ${RESET}seconds )"
		done

		sleep 2
		show_message "waiting " green bold
		LAST_NO=$(ps -aux | grep "sudo .*hyper pod" | grep -v grep | wc -l)
		BEGIN_TS=$(date +"%s")
		echo -n ${LAST_NO}
		until [ $(ps -aux | grep "sudo .*hyper pod" | grep -v grep | wc -l) -eq 0 ]
		do
			echo -n "."
			if [ "${LAST_NO}" != "$(ps -aux | grep "sudo .*hyper pod" | grep -v grep | wc -l)" ]
			then
				LAST_NO=$(ps -aux | grep "sudo .*hyper pod" | grep -v grep | wc -l)
				echo -n ${LAST_NO}
			fi
		done
		if [ "${LAST_NO}" != "0" ]
		then
			echo "0"
		fi

		END_TS=$(date +"%s")
		show_message "finish" green bold
		show_message "create ${PURPLE}${CHOICE}${YELLOW} pods in ${PURPLE}$((END_TS-BEGIN_TS))${YELLOW} (seconds)" yellow bold

		AFTER=`sudo ${HYPER_CLI}  list pod | grep "pod-.*running" | wc -l`

		echo
		echo "PENDING POD(S)  : ${PURPLE}${CNT}${RESET}"
		echo "ORIG running    : ${PURPLE}${BEFORE}${RESET}"
		echo "CURRENT running : ${PURPLE}${AFTER}${RESET}"

		if [ ${CNT} -ne $((AFTER-BEFORE)) ]
		then
			show_message "require ${WHITE}${CNT}${RED} pods running, but now has ${WHITE}$((AFTER-BEFORE))${RED} pods running " red bold
			echo "----------------------------"
			echo "error message in log:"
			echo "----------------------------"
			#grep -i --color -n "ERROR" ${LINK_CURRENT}
			grep -B2 real ${LINK_CURRENT} | grep -v real | grep -v "\-\-" | grep -v "^$" | grep -i --color -n "ERROR"
		fi

		if [ "${TIME_TYPE}" == "(system time)" ]
		then
			#stat by system time
			STAT_RLT=$(grep  -A3 "^POD id is pod-" ${LOG_FILE} | grep real | cut -d"m" -f2 | cut -d"s" -f1 \
				| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%.0f | %.0f | %.0f",min*1000,max*1000,total/count*1000}else{print ""}; }')
		else
			#stat by internal time
			STAT_RLT=$(grep  -A1 "^POD id is pod-"  ${LOG_FILE}  | grep "^Time to run a POD" | awk '{print $7}' \
				| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%.0f | %.0f | %.0f",min,max,total/count}else{print ""}; }')
		fi

		show_message "startup time stat result (ms): ${WHITE}[ include ${PURPLE}$((AFTER-BEFORE))${RESET} running pods ] " yellow bold

		#old format
		# echo "========================="
		# echo -e "min\tmax\tavg"
		# echo "-------------------------"
		# echo "${PURPLE}${STAT_RLT}${RESET}"
		# echo "========================="
		# echo "${CYAN}${TIME_TYPE}${RESET}"

		#new format for markdown
		echo "${BOLD}${GREEN}| min | max | avg |"
		echo "| --- | --- | --- |"
		echo "| ${STAT_RLT} |${RESET}"
		echo
		echo "time type   : ${CYAN}${TIME_TYPE}${RESET}"
		echo "hyper client: ${CYAN}${HYPER_CLI_TYPE}${RESET}"

		echo -e "\nlog file: [ ${BLUE} ${LINK_CURRENT} ${RESET}]"


	else
		show_message "please input a number, [ $CHOICE ] isn't a valid number(>=1)" red bold
	fi
fi


show_message "Done." green
