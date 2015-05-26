#!/bin/bash
# vim: ft=sh sw=2 ts=2 st=2 sts=2 et
#
# NOTE
#
# see the bottom of this script for all the test batteries executed as
# functions -- comment out what you don't want to run!
#
# edit the variables below to tweak some common parameters.

#max_requests=100000
max_requests=1000
# by default, set to number of cpus
# just change this to a number if you want to use something fixed
num_threads=$(cat /proc/cpuinfo | grep processor | wc -l)
image_name=hyper:sysbench
pod_file=hyper-sysbench


header() {
  echo
  echo "----------------------------------------------------------------------"
  echo $*
  echo "----------------------------------------------------------------------"
  echo
}

build_docker_image() {
  header "Building Docker Image"
  docker build -t $image_name .
}

install_sysbench() {
  type sysbench > /dev/null 2>&1
  if [ $? -ne 0 ];then
    header "Installing sysbench locally if not already installed"
    #apt-get install -y sysbench
    sudo apt-get -y install bzr make automake libc-dev  libtool
    bzr branch lp:~sysbench-developers/sysbench/0.5 ~/sysbench-0.5
    cd ~/sysbench-0.5
    ./autogen.sh
    ./configure --without-mysql
    make
    sudo make install
    cd ${BASE_DIR}
  else
    echo "sysbench already installed"
    sysbench --version
  fi
}

generate_pod() {
  header "Dynamic update vcpu in pod json"
  cat "${pod_file}.pod.tmpl" | ${BASE_DIR}/../../util/jq ".resource.vcpu=${num_threads}" > "${pod_file}.tmp"
  ls -l "${pod_file}.pod" && cat "${pod_file}.pod" | ${BASE_DIR}/../../util/jq "."
}

hyper_get_container_id() {
  POD_NAME=$(cat "${pod_file}.pod" | ${BASE_DIR}/../../util/jq -r ".id" )
  if [ "${POD_NAME}" == "" ];then
    echo -n " "
  else
    POD_ID=$(hyper list | grep "${POD_NAME}.*running" | awk '{print $1}')
    if [ "${POD_ID}" == "" ];then
      echo -n " "
    else
      CNTR_ID=$(hyper list container | grep "${POD_ID}.*online" | awk '{print $1}')
      if [ "${CNTR_ID}" == "" ];then
        echo -n " "
      else
        echo -n "${CNTR_ID}"
      fi
    fi
  fi
}

###########################################

run_cpu_tests() {
  header "CPU Performance Test - Host Machine "
  sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=cpu run

  header "CPU Performance Test - Docker"
  docker run -t $image_name sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=cpu run

  header "CPU Performance Test - Hyper"
  CONTAINER_ID=$(hyper_get_container_id)
  if [ "${CONTAINER_ID}" == " " ];then
    sudo hyper pod ${pod_file}.pod
  fi
  CONTAINER_ID=$(hyper_get_container_id)
  if [ "${CONTAINER_ID}" == " " ];then
    echo "create hyper pod failed"
    exit 1
  fi
  sudo hyper exec ${CONTAINER_ID} /usr/local/bin/sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=cpu run
}

run_memory_tests() {
  for oper in read write
  do
    for mode in seq rnd
    do
      header "Host Machine Memory Test: $mode $oper"
      sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=memory --memory-oper=${oper} --memory-access-mode=${mode} run
      header "Docker Memory Test: $mode $oper"
      docker run -t $image_name sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=memory --memory-oper=${oper} --memory-access-mode=${mode} run
    done
  done
}

iotest() {
  echo "sysbench --test=fileio prepare && sysbench --num-threads=${num_threads} --max-requests=${max_requests} --file-test-mode=$1 --test=fileio run; sysbench --test=fileio cleanup"
}

run_io_tests() {
  for io_test in $io_tests
  do
    header "Host Machine: I/O Test $io_test"

    bash -c "$(iotest $io_test)"

    header "Docker: I/O Test $io_test"
    docker run -t $image_name bash -c "$(iotest $io_test)"
  done
}



######################################################################
# main
######################################################################
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ $# -eq 1 ]; then

  case "$1" in
    init)
      echo "[ init ]"
      build_docker_image
      install_sysbench
    ;;
    test)
      echo "[ start ]"
      #prepare
      generate_pod
      #start test
      run_cpu_tests
      #run_memory_tests
      #run_io_tests
    ;;
    *)
      echo "usage: ./bench.sh <init>|<test>"
  esac
else
  echo "usage: ./bench.sh <init>|<test>"
fi
