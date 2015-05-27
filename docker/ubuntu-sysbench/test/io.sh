num_threads=$1
max_requests=$2
file_total_size=$3
file_test_mode=$4

/usr/local/bin/sysbench --test=fileio prepare
/usr/local/bin/sysbench --num-threads=${num_threads} --max-requests=${max_requests} --file-test-mode=${file_test_mode} --test=fileio --file-total-size=${file-total-size}M run
/usr/local/bin/sysbench --test=fileio cleanup
