#!/bin/bash
#~/test.sh
cd /root/
rm cpu.log -rf
touch cpu.log
echo `date +'%F %T'` 1'(1,10000)';sysbench --test=cpu --cpu-max-prime=10000 --num-threads=1 run | grep 'total time:' >>cpu.log
echo `date +'%F %T'` 2'(1,50000)';sysbench --test=cpu --cpu-max-prime=50000 --num-threads=1 run | grep 'total time:' >>cpu.log
echo `date +'%F %T'` 3'(1,100000)';sysbench --test=cpu --cpu-max-prime=100000 --num-threads=1 run | grep 'total time:' >>cpu.log
echo `date +'%F %T'` 4'(2,10000)';sysbench --test=cpu --cpu-max-prime=10000 --num-threads=2 run | grep 'total time:' >>cpu.log
echo `date +'%F %T'` 5'(2,50000)';sysbench --test=cpu --cpu-max-prime=50000 --num-threads=2 run | grep 'total time:' >>cpu.log
echo `date +'%F %T'` 6'(2,100000)';sysbench --test=cpu --cpu-max-prime=100000 --num-threads=2 run | grep 'total time:' >>cpu.log
echo `date +'%F %T'`' Done'
echo
cat cpu.log

