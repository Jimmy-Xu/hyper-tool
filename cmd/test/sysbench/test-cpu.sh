#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh


show_message "test cpu" green


LOG_TS=$(date +'%s')
LOG_DIR=${BASE_DIR}/../../../log/sysbench/cpu
#ensure log dir
mkdir -p ${LOG_DIR}

#create logfile
LOG_FILE=${LOG_DIR}/cpu-${LOG_TS}.log
touch ${LOG_FILE}

#create link
LINK_CURRENT=${BASE_DIR}/../../../log/sysbench/cpu/current
if [ -f ${LINK_CURRENT} ]
then
	show_message "log file link exist, will remove it first" yellow bold
	rm ${LINK_CURRENT}
fi
ln -s ${LOG_FILE} ${LINK_CURRENT}

CPU_MAX_PRIME=(10000 50000 100000)
NUM_THREADS=(1 2)

idx=1
for n_thread in ${NUM_THREADS[@]}
do
	for n_cpu_prime in ${CPU_MAX_PRIME[@]}
	do
		MSG="[`date +'%F %T'`] No. ${idx} num-threads: ${n_thread} cpu-max-prime: ${n_cpu_prime}"
		echo ${MSG}
		echo -n "${MSG}" >> ${LINK_CURRENT}
		sysbench --test=cpu --num-threads=${n_thread} --cpu-max-prime=${n_cpu_prime} run | grep 'total time:' >> ${LINK_CURRENT}
		idx=$((idx+1))
	done

done

echo -e "\nlog file: [ ${BLUE} ${LINK_CURRENT} ${RESET}]"
show_message "cpu sysbench result:" green bold
cat ${LINK_CURRENT}


show_message "Done." green
