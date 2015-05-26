##build
docker build -t ubuntu:sysbench .

##usage
docker run -it --name test --cpuset=0,1 --memory=2048m ubuntu:sysbench /bin/bash
docker restart 32538b49864c
docker exec -it 32538b49864c /bin/bash

##do sysbench test
./run.sh