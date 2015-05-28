#!/bin/bash

LOG_FILE="bench.log"

dos2unix log/${LOG_FILE}

cat log/${LOG_FILE} | grep -A22 "CPU Performance Test" | awk -f awk/cpu_report.awk
