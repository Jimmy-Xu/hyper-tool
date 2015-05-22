#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh


show_message "view memory usage" green


#number of  qemu process
NUM_QEMU_PROC=$(ps aux | sed -n '1p;/'${QEMU_PROCESS}'/p' | grep -v sed| grep qemu | wc -l)

show_message "QEMU process memory usage(KiB): ( ${PURPLE}${NUM_QEMU_PROC}${GREEN} qemu process )" green bold
echo "================================"
echo -e "     min\tmax\tavg"
echo "--------------------------------"
STAT_RLT_RSS=$(ps aux | sed -n '1p;/'${QEMU_PROCESS}'/p' | grep -v sed | awk '{print $2,$5,$6,$11}'| grep qemu | cut -d" " -f3 \
| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%s\t%s\t%s",min,max,total/count}else{print ""}; }')
echo "RSS: ${PURPLE}${STAT_RLT_RSS}${RESET}"
echo "================================"

STAT_RLT_VSZ=$(ps aux | sed -n '1p;/'${QEMU_PROCESS}'/p' | grep -v sed | awk '{print $2,$5,$6,$11}'| grep qemu | cut -d" " -f2 \
| awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1< min) {min=$1}; total+=$1; count+=1} END { if (count>0){ printf "%s\t%s\t%s",min,max,total/count}else{print ""}; }')
echo "VSZ: ${PURPLE}${STAT_RLT_VSZ}${RESET}"
echo "================================"


show_message "Done." green
