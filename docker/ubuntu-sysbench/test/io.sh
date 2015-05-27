#!/bin/bash

_NUM_THREADS=$1
_MAX_REQUESTS=$2
_FILE_SIZE=$3
_FILE_TEST_MODE=$4

echo "_NUM_THREADS   : ${_NUM_THREADS}"
echo "_MAX_REQUESTS  : ${_MAX_REQUESTS}"
echo "_FILE_SIZE     : ${_FILE_SIZE}"
echo "_FILE_TEST_MODE: ${_FILE_TEST_MODE}"

/usr/local/bin/sysbench --test=fileio --file-total-size=${_FILE_SIZE}G prepare
/usr/local/bin/sysbench --test=fileio --file-total-size=${_FILE_SIZE}G --num-threads=${_NUM_THREADS} --max-requests=${_MAX_REQUESTS} --file-test-mode=${_FILE_TEST_MODE} run
/usr/local/bin/sysbench --test=fileio --file-total-size=${_FILE_SIZE}G cleanup
