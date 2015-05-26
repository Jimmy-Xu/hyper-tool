num_threads=$1
max_requests=$2
file_test_mode=$3

/usr/local/bin/sysbench --test=fileio prepare
/usr/local/bin/sysbench --num-threads=${num_threads} --max-requests=${max_requests} --file-test-mode=${file_test_mode} --test=fileio run
/usr/local/bin/sysbench --test=fileio cleanup
