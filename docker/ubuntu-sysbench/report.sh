#!/bin/bash

LOG_DIR=log
AWK_DIR=awk
LOG_FILE="bench.log"

dos2unix ${LOG_DIR}/${LOG_FILE}

cat ${LOG_DIR}/${LOG_FILE} | grep -A24 "CPU Performance Test -" | awk -f ${AWK_DIR}/cpu_report.awk

echo

cat ${LOG_DIR}/${LOG_FILE} | grep -A26 "Memory Test -" | awk -f ${AWK_DIR}/mem_report.awk

echo

cat ${LOG_DIR}/${LOG_FILE} | grep -A40 "IO Test -" | awk -f ${AWK_DIR}/io_report.awk
