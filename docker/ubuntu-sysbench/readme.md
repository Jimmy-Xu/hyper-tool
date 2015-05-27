##build
docker build -t ubuntu:sysbench .

##usage
docker run -it --name test_cpu --cpuset-cpus=0,1 --memory=2048m ubuntu:sysbench /bin/bash
docker restart 32538b49864c
docker exec -it 32538b49864c /bin/bash

##do sysbench test
 ./test.sh 1 && echo "---------" &&  ./test.sh 2

########################################

#build docker image, create test pod
./bench.sh init

#test cpu,memory,io in host, docker and hyper
./bench.sh test