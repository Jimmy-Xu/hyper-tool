#!/bin/bash

LOG_DIR=log
AWK_DIR=awk

dos2unix ${LOG_DIR}/*.log

cat ${LOG_DIR}/cpu.log | grep -A24 "CPU Performance Test -" | awk -f ${AWK_DIR}/cpu_report.awk

echo

cat ${LOG_DIR}/mem.log | grep -A26 "Memory Test -" | awk -f ${AWK_DIR}/mem_report.awk

echo

cat ${LOG_DIR}/io.log | grep -A50 "IO Test -" | awk -f ${AWK_DIR}/io_report.awk
