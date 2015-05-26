#!/bin/bash

/usr/local/bin/sysbench --test=fileio prepare
/usr/local/bin/sysbench --num-threads=${num_threads} --max-requests=${max_requests} --file-test-mode=$1 --test=fileio run
/usr/local/bin/sysbench --test=fileio cleanup
