#!/bin/bash

LOG_DIR=log
AWK_DIR=awk
LOG_FILE="bench.log"

dos2unix ${LOG_DIR}/${LOG_FILE}

cat ${LOG_DIR}/${LOG_FILE} | grep -A24 "CPU Performance Test" | awk -f ${AWK_DIR}/cpu_report.awk
