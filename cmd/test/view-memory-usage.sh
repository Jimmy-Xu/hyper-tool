#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh


show_message "view memory usage" green

#QEMU process memory usage
STAT_RLT_RSS=$(ps aux | sed -n '1p;/'${QEMU_PROCESS}'/p' | grep -v sed | awk '{print $2,$5,$6,$11}'| grep qemu | cut -d" " -f3 \
| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%5.0f | %5.0f | %5.0f",min/1024,max/1024,total/count/1024}else{print ""}; }')

STAT_RLT_VSZ=$(ps aux | sed -n '1p;/'${QEMU_PROCESS}'/p' | grep -v sed | awk '{print $2,$5,$6,$11}'| grep qemu | cut -d" " -f2 \
| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%5.0f | %5.0f | %5.0f",min/1024,max/1024,total/count/1024}else{print ""}; }')

#number of  qemu process
NUM_QEMU_PROC=$(ps aux | sed -n '1p;/'${QEMU_PROCESS}'/p' | grep -v sed| grep qemu | wc -l)
show_message "QEMU process memory usage(MiB): ( ${PURPLE}${NUM_QEMU_PROC}${GREEN} qemu process )" green

#old format
# echo "==========================================="
# echo -e "               min        max     avg"
# echo "==========================================="
# echo "RSS(VmRSS) : ${PURPLE}${STAT_RLT_RSS}${RESET}"
# echo "-------------------------------------------"
# echo "VSZ(VmSize): ${PURPLE}${STAT_RLT_VSZ}${RESET}"
# echo "==========================================="

#new format for markdown
echo "${BOLD}${GREEN}|  -  | min | max | avg |"
echo "| --- | --- | --- | --- |"
echo "|RSS(VmRSS) | ${STAT_RLT_RSS} |"
echo "|VSZ(VmSize)| ${STAT_RLT_VSZ} |${GREEN}"



#memory usage in container
LOG_TS=$(date +'%s')
LOG_DIR=${BASE_DIR}/../../log/memory/${LOG_TS}
#ensure log dir
mkdir -p ${LOG_DIR}

#create logfile
LOG_FILE=${LOG_DIR}/memory-in-container.log
touch ${LOG_FILE}

#create link
LINK_CURRENT=${BASE_DIR}/../../log/memory/current
if [ -d ${LINK_CURRENT} ]
then
	show_message "log dir link exist, will remove it first" yellow bold
	rm ${LINK_CURRENT}
fi
ln -s ${LOG_DIR} ${LINK_CURRENT}


cd ${LINK_CURRENT}
if [ -d ${LINK_CURRENT} ]
then
	HYPER_CLI="${GOPATH}/src/${HYPER_CLONE_DIR}/hyper"
	#show_message "${GREEN}Entering dir ${BLUE}${LINK_CURRENT}${GREEN}, hyper client path ${HYPER_CLI}" grep bold
	show_message "execute command like '${PURPLE}sudo ${HYPER_CLI} exec <container-id> top -b -n1${RESET}' " green
	cd ${LINK_CURRENT}
	sudo echo

	#count container number
	NUM_OL_CONTAINER=$(sudo ${HYPER_CLI} list container | grep online | wc -l)
	#echo "sudo ${HYPER_CLI} list container | grep online | wc -l"

	rm -rf view-container-mem.sh
	sudo ${HYPER_CLI} list container | grep online | awk -v hyper=${HYPER_CLI} '{printf "sudo "hyper" exec %s top -b -n1 \n",$1}' >> view-container-mem.sh
	chmod u+x view-container-mem.sh && ./view-container-mem.sh > ./container-mem.log 2>&1
	if [ $? -eq 0 ]
	then
		STAT_RLT_TOTAL=$(grep "^KiB Mem" container-mem.log | awk '{print $3}' | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%5.0f | %5.0f | %5.0f",min/1024,max/1024,total/count/1024}else{print ""}; }')
		STAT_RLT_USED=$( grep "^KiB Mem" container-mem.log | awk '{print $5}' | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%5.0f | %5.0f | %5.0f",min/1024,max/1024,total/count/1024}else{print ""}; }')
		STAT_RLT_FREE=$( grep "^KiB Mem" container-mem.log | awk '{print $7}' | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%5.0f | %5.0f | %5.0f",min/1024,max/1024,total/count/1024}else{print ""}; }')

		#old format
		# echo "==========================================="
		# echo -e "         min      max     avg"
		# echo "==========================================="
		# echo "Total: ${PURPLE}${STAT_RLT_TOTAL}${RESET}"
		# echo "-------------------------------------------"
		# echo "Used : ${PURPLE}${STAT_RLT_USED}${RESET}"
		# echo "-------------------------------------------"
		# echo "Free : ${PURPLE}${STAT_RLT_FREE}${RESET}"
		# echo "==========================================="

		#new format for markdown
		show_message "memory usage in container (MiB): ( ${PURPLE}${NUM_OL_CONTAINER}${GREEN} online container )" green
		echo "${BOLD}${GREEN}|  -  | min | max | avg |"
		echo "| --- | --- | --- | --- |"
		echo "|Total| ${STAT_RLT_TOTAL} |"
		echo "|Used | ${STAT_RLT_USED} |"
		echo "|Free | ${STAT_RLT_FREE} |${RESET}"

	else
		show_message "stat memory usage in container failed:(" red bold
		cat ./container-mem.log
	fi

	show_message "log dir: [ ${BLUE}${LINK_CURRENT}${GREEN} ]" green bold
else
	show_message "${LINK_CURRENT} isn't exist, cancel"
fi

show_message "Done." green
