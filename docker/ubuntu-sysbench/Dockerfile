FROM ubuntu:14.04
MAINTAINER xjimmy@mc2.io

ENV BASE_DIR /root
ENV PATH=/usr/local/bin:$PATH

############################################################
# install common packages
############################################################
RUN apt-get -y clean
RUN apt-get -y update
RUN apt-get -y install bzr make automake libc-dev  libtool

############################################################
# compile sysbench from source
############################################################
WORKDIR $BASE_DIR
RUN bzr branch lp:~sysbench-developers/sysbench/0.5  sysbench-0.5
WORKDIR sysbench-0.5
RUN ./autogen.sh
RUN ./configure --without-mysql
RUN make
RUN make install

COPY ./test.sh $BASE_DIR/test.sh
WORKDIR $BASE_DIR

CMD sysbench --version

