#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh


# if [ $# -eq 1 -a "$1" == "2" ]
# then
# 	TIME_TYPE="(internal time)"
# else
# 	TIME_TYPE="(system time)"
# fi


show_message "test pod replace time ${TIME_TYPE}" green

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

		LOG_TS=$(date +'%s')
		LOG_DIR=${BASE_DIR}/../../log/replace/${LOG_TS}
		#ensure log dir
		mkdir -p ${LOG_DIR}

		LOG_FILE=${LOG_DIR}/time-replace.log
		LOG_FILE_RUNNING=${LOG_DIR}/pod-running.log
		LOG_FILE_CREATED=${LOG_DIR}/pod-created.log

		touch ${LOG_FILE}
		touch ${LOG_FILE_RUNNING}
		touch ${LOG_FILE_CREATED}

		CNT=$CHOICE
		#create running pod(s)
		BEFORE=`sudo ./hyper list pod | grep "pod-.*running" | wc -l`
		show_message "[Step 1] create ${WHITE}${CHOICE}${GREEN} ${BLUE}running${GREEN} pod(s)..." green
		for i in `seq 1 $CNT`
		 do
		   echo -n "No. $i "`date +"%F %T" `
		   START_TS=$(date +'%s')
		   (time sudo ./hyper pod test/ubuntu.pod) >>"${LOG_FILE_RUNNING}" 2>&1
		   END_TS=$(date +'%s')
		   echo "( ${PURPLE}$((END_TS-START_TS)) ${RESET}seconds )"
		done
		AFTER=`sudo ./hyper  list pod | grep "pod-.*running" | wc -l`
		echo "STARTED POD(S)  : ${PURPLE}${CNT}${RESET}"
		echo "ORIG running    : ${PURPLE}${BEFORE}${RESET}"
		echo "CURRENT running : ${PURPLE}${AFTER}${RESET}"

		#create created pod(s)
		BEFORE=`sudo ./hyper list pod | grep "pod-.*created" | wc -l`
		show_message "[Step 2] create ${WHITE}${CHOICE}${GREEN} ${YELLOW}created${GREEN} pod(s)..." green
		for i in `seq 1 $CNT`
		 do
		   echo -n "No. $i "`date +"%F %T" `
		   START_TS=$(date +'%s')
		   (time sudo ./hyper create test/ubuntu.pod) >>"${LOG_FILE_CREATED}" 2>&1
		   END_TS=$(date +'%s')
		   echo "( ${PURPLE}$((END_TS-START_TS)) ${RESET}seconds )"
		done
		AFTER=`sudo ./hyper  list pod | grep "pod-.*created" | wc -l`
		echo "CREATED POD(S)  : ${PURPLE}${CNT}${RESET}"
		echo "ORIG created    : ${PURPLE}${BEFORE}${RESET}"
		echo "CURRENT created : ${PURPLE}${AFTER}${RESET}"

		#test replace
		show_message "[Step 3] tets replace pod(s)..." green


		OLD_IFS="$IFS" #save current IFS
		IFS=$'\x0A' #enter key
		POD_OLD=($(grep " pod-.*" ${LOG_FILE_RUNNING} | awk '{print $4}'))
		POD_NEW=($(grep " pod-.*" ${LOG_FILE_CREATED} | awk '{print $4}'))
		IFS=${OLD_IFS}

		echo "${WHITE}number of old pod(${BLUE}running${WHITE}) ${PURPLE}: ${#POD_OLD[@]} ${RESET}"
		echo "${WHITE}number of new pod(${YELLOW}created${WHITE}) ${PURPLE}: ${#POD_NEW[@]} ${RESET}"

		if [ ${#POD_OLD[@]} -eq ${#POD_NEW[@]} ]
		then
			#number of old pod is same as new pod

			######################################################
			show_message "check pod status..." green

			#echo -e "running pod: \n"${POD_OLD[@]}
			#echo -e "created pod: \n"${POD_NEW[@]}

			#generate POD_OLD_LIST
			for (( i = 0 ; i < ${#POD_OLD[@]} ; i++ ))
			do
				if [ $i -eq 0 ]
				then
					POD_OLD_LIST=${POD_OLD[$i]}
				else
					POD_OLD_LIST+="|${POD_OLD[$i]}"
				fi
			done

			#generate POD_NEW_LIST
			for (( i = 0 ; i < ${#POD_NEW[@]} ; i++ ))
			do
				if [ $i -eq 0 ]
				then
					POD_NEW_LIST=${POD_NEW[$i]}
				else
					POD_NEW_LIST+="|${POD_NEW[$i]}"
				fi
			done

			#echo -e "running pod: \n"${POD_OLD_LIST}
			#echo -e "created pod: \n"${POD_NEW_LIST}

			echo "${BOLD}${WHITE}===================================="
			echo "old pod status(${GREEN}running${YELLOW}${WHITE}):"
			echo "====================================${RESET}"
			sudo ./hyper list | grep -E "("${POD_OLD_LIST}")" | grep -n -E "(running|created)" --color
			NUM_RUNNING=$(sudo ./hyper list | grep -E "("${POD_OLD_LIST}")" | grep "pod-.*running" | wc -l )

			echo "${BOLD}${WHITE}===================================="
			echo "new pod status(${YELLOW}created${YELLOW}${WHITE}):"
			echo "====================================${RESET}"
			sudo ./hyper list | grep -E "("${POD_NEW_LIST}")" | grep -n -E "(running|created)" --color
			NUM_CREATED=$(sudo ./hyper list | grep -E "("${POD_NEW_LIST}")" | grep "pod-.*created" | wc -l )


			echo "${CYAN}===================================="
			echo "check result:"
			echo "====================================${RESET}"
			echo "${BOLD}running pod${RESET}"
			echo " >required   : ${PURPLE}${#POD_OLD[@]}${RESET}"
			echo " >real       : ${PURPLE}${NUM_RUNNING}${RESET}"
			echo
			echo "${BOLD}created pod${RESET}"
			echo " >required   : ${PURPLE}${#POD_NEW[@]}${RESET}"
			echo " >real       : ${PURPLE}${NUM_CREATED}${RESET}"

			if [ ${#POD_OLD[@]} -eq ${NUM_RUNNING} -a ${#POD_NEW[@]} -eq ${NUM_CREATED} ]
			then
				######################################################
				show_message "start replace..." green
				for (( i = 0 ; i < ${#POD_OLD[@]} ; i++ ))
				do
					echo "$((i+1)): ${PURPLE}sudo ./hyper replace -o ${POD_OLD[$i]} -n ${POD_NEW[$i]} ${RESET}"
					( time sudo ./hyper replace -o ${POD_OLD[$i]} -n ${POD_NEW[$i]} ) >>"${LOG_FILE}" 2>&1
				done

				show_message "replace time stat (ms):" yellow bold
				echo "========================="
				echo -e "min\tmax\tavg"
				echo "-------------------------"
				STAT_RLT=$(grep -A1 "^Successful to replace" "${LOG_FILE}" | grep real | cut -d"m" -f2 | cut -d"s" -f1 \
				| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%s\t%s\t%s",min*1000,max*1000,total/count*1000}else{print ""}; }')

				echo "${PURPLE}${STAT_RLT}${RESET}"
				echo "========================="

			else
				show_message "number of running pod is different with created pod, can not replace" red bold
			fi

		else
			show_message "number of old pod is different with new pod, can not replace" red bold
		fi


	else
		show_message "please input a number, [ $CHOICE ] isn't a valid number(>=1)" red bold
	fi
fi


show_message "Done." green