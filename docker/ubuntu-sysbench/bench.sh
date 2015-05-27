#!/bin/bash

#######################################
# Env
#######################################
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
JQ=${BASE_DIR}/../../util/jq
DRY_RUN="true" #true|false

#######################################
# Parameter
#######################################

TOTAL_MEMSIZE=""
TOTAL_CPUNUM=""

#cpu/memory resource for docker & hyper
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
MEMORY_SIZE=$((1*1024))  #(MiB)

#docker image and pod
DOCKER_IMAGE="hyper:sysbench"
POD_FILENAME="hyper-sysbench"
POD_NAME=${POD_FILENAME}
POD_DIR="pod"

#######################################
# Constant
#######################################
#Color Constant
BLACK=`tput setaf 0`   #<reserved>
RED=`tput setaf 1`     #error
GREEN=`tput setaf 2`   #success
YELLOW=`tput setaf 3`  #warning
BLUE=`tput setaf 4`    #infomation
PURPLE=`tput setaf 5`  #exception
CYAN=`tput setaf 6`    #<reserved>
WHITE=`tput setaf 7`   #normal
LIGHT=`tput bold `     #light color
RESET=`tput sgr0`      #restore color setting

#######################################
# Function
#######################################
function title() {
  echo
  echo "────────────────────────────────────────────────────────"
  echo $@
  echo "────────────────────────────────────────────────────────"
}

function fetch_total_cpu_memory() {
  TOTAL_MEMSIZE=$(cat /proc/meminfo | grep MemTotal | awk '{printf "%0.f", $2/1024}')
  TOTAL_CPUNUM=$(cat /proc/cpuinfo | grep processor | wc -l)
}

function build_dockerfile() {
  title "Building Dockerfile for image ${DOCKER_IMAGE}"
  sudo docker build -t ${DOCKER_IMAGE} .
}

function install_sysbench() {
  type sysbench > /dev/null 2>&1
  if [ $? -ne 0 ];then
    title "Installing sysbench in host os"
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

function generate_pod() {
  title "Dynamic update vcpu in pod json"
  #set cpu
  cat "${POD_DIR}/${POD_FILENAME}.pod.tmpl" | ${JQ} ".resource.vcpu=${CPU_NUM}" > "${POD_DIR}/${POD_FILENAME}.tmp"
  cat "${POD_DIR}/${POD_FILENAME}.tmp" | ${JQ} ".resource.memory=${MEMORY_SIZE}" > "${POD_DIR}/${POD_FILENAME}.pod"
  \rm -rf "${POD_DIR}/${POD_FILENAME}.tmp"
  ls -l "${POD_DIR}/${POD_FILENAME}.pod" && cat "${POD_DIR}/${POD_FILENAME}.pod" | ${JQ} "."
  echo "generate pod done."
}

function run_pod() {
  title "Run test pod"
  CONTAINER_ID=$(hyper_get_container_id)
  if [ "${CONTAINER_ID}" == " " ];then
    echo "sudo hyper pod ${POD_DIR}/${POD_FILENAME}.pod"
    sudo hyper pod ${POD_DIR}/${POD_FILENAME}.pod
    if [ $? -ne 0 ];then
      echo "create pod failed,exit!"
      exit 1
    fi
    sleep 3
  else
    echo "${CONTAINER_ID} already running"
  fi
  echo "run pod done."
}

function hyper_get_container_id() {
  POD_NAME=$(cat "${POD_DIR}/${POD_FILENAME}.pod" | ${JQ} -r ".id" )
  if [ "${POD_NAME}" == "" ];then
    echo -n " "
  else
    POD_ID=$(sudo hyper list | grep "${POD_NAME}.*running" | awk '{print $1}' | head -n 1 )
    if [ "${POD_ID}" == "" ];then
      echo -n " "
    else
      CNTR_ID=$(sudo hyper list container | grep "${POD_ID}.*online" | awk '{print $1}')
      if [ "${CNTR_ID}" == "" ];then
        echo -n " "
      else
        echo -n "${CNTR_ID}"
      fi
    fi
  fi
}

function clean_pod() {
  title "Clean old pod with name ${POD_NAME}"
  echo -e "\n1.stop all runnign ${POD_NAME}"
  sudo hyper list | grep "${POD_NAME}.*running" | awk '{print $1}' | xargs -i sudo hyper stop {}

  echo -e "\n2.rm all pending ${POD_NAME}"
  sudo hyper list | grep "${POD_NAME}.*pending" | awk '{print $1}' | xargs -i sudo hyper rm {}

  echo -e "\n3.list pod ${POD_NAME}"
  sudo hyper list | sed -n '1p;/'${POD_NAME}'/p'
  echo -e "\nclean done"
}

function show_test_cmd() {
  echo "${YELLOW}$1 "
}

function pause() {
  read -n 1 -p "${LEFT_PAD}${BLUE}Press any key to continue...${RESET}"
}

function input_cpu_number() {

  SET_CPU_DONE="false"
  until [[ "${SET_CPU_DONE}" == "true" ]];do
    echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}number${PURPLE} of vcpu${RESET}(>=1,press 'Enter' for 1):"
    read CHOICE
    if [ ! -z ${CHOICE} ];then
      if [[ $CHOICE =~ ^[[:digit:]]+$ ]] && [[ ${CHOICE} -ge 1 ]];then
        CPU_NUM=${CHOICE}
        SET_CPU_DONE="true"
      else
        echo "${CHOICE} is an invalid number, please input a valid cpu number!"
      fi
    else
      CPU_NUM=1
      SET_CPU_DONE="true"
    fi
  done
}

function input_memory_size() {

  SET_MEM_DONE="false"
  until [[ "${SET_MEM_DONE}" == "true" ]];do
    echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}size${PURPLE} of memory${RESET}(MB)(>=28,press 'Enter' for 1024):"
    read CHOICE
    if [ ! -z ${CHOICE} ];then
      if [[ $CHOICE =~ ^[[:digit:]]+$ ]] && [[ ${CHOICE} -ge 28 ]];then
        MEMORY_SIZE=${CHOICE}
        SET_MEM_DONE="true"
      else
        echo "${CHOICE} is an invalid number, please input a valid memory size!"
      fi
    else
      MEMORY_SIZE=1024
      SET_MEM_DONE="true"
    fi
  done
}


function generate_test_parameter() {
  #cpuset-cpus for docker
  CPU_SET=($(seq 0 $((CPU_NUM-1))))
  CPU_SET="${CPU_SET[@]}"

  #sysbench cpu test parameter
  NUM_THREADS=${CPU_NUM}
  MAX_REQUESTS=$((CPU_NUM*1000))
  CPU_MAX_PRIME=$((CPU_NUM*1000))
}


function show_test_parameter() {
  echo "${CYAN}"
  title "List all test parameter"

  echo "----------- total resource -----------"
  echo " TOTAL_MEMSIZE : ${WHITE}${TOTAL_MEMSIZE}${CYAN} (MB)"
  echo " TOTAL_CPUNUM  : ${WHITE}${TOTAL_CPUNUM}${CYAN}"
  echo

  echo "---------- resource to test ----------"
  echo " CPU_NUM       : ${WHITE}${CPU_NUM}${CYAN}"
  echo " MEMORY_SIZE   : ${WHITE}${MEMORY_SIZE}${CYAN} (MB)"
  echo

  echo "------------ docke image -------------"
  echo " DOCKER_IMAGE: ${WHITE}${DOCKER_IMAGE}${CYAN}"
  echo

  echo "------- parameter for docker --------"
  echo " --memory=${WHITE}${MEMORY_SIZE}m${CYAN}"
  echo " --cpuset-cpus=${WHITE}${CPU_SET/ /,}${CYAN}"
  echo

  echo "--------- cpu test parameter----------"
  echo " NUM_THREADS   : ${WHITE}${NUM_THREADS}${CYAN}"
  echo " MAX_REQUESTS  : ${WHITE}${MAX_REQUESTS}${CYAN}"
  echo " CPU_MAX_PRIME : ${WHITE}${CPU_MAX_PRIME}${CYAN}"

  #check parameter
  if [ -z "${CPU_NUM}" -o -z "${MEMORY_SIZE}" -o -z "${DOCKER_IMAGE}" -o -z "${CPU_SET}" -o -z "${NUM_THREADS}" -o -z "${MAX_REQUESTS}" -o -z "${CPU_MAX_PRIME}" ];then
    echo "Error, some parameter is empty, exit!"
    exit 1
  else
    echo
    pause
  fi
  echo "${RESET}"
}

###########################################

function start_test() {
  TEST_TARGET=("$1")
  TEST_ITEM=("$2")
  echo "${LIGHT}${YELLOW}start test [${TEST_TARGET}] [${TEST_ITEM}]${RESET}"

  #1 get system cpu and memory
  fetch_total_cpu_memory

  #2 prepare test parameter
  input_cpu_number
  input_memory_size
  generate_test_parameter
  show_test_parameter

  #3 create hyper pod
  generate_pod
  run_pod

  #4 start test
  if (echo "${TEST_ITEM[@]}" | grep -w "cpu" &>/dev/null);then
    do_cpu_test "${TEST_TARGET}"
  elif (echo "${TEST_ITEM[@]}" | grep -w "memory" &>/dev/null);then
    do_memory_test "${TEST_TARGET}"
  elif (echo "${TEST_ITEM[@]}" | grep -w "io" &>/dev/null);then
    do_io_test "${TEST_TARGET}"
  else
    echo "no any test item, only support cpu,memory and io performance test,exit!"
    exit 1
  fi
}

function do_cpu_test() {
  TEST_TARGET=("$1")

  if (echo "${TEST_TARGET[@]}" | grep -w "host" &>/dev/null);then
    echo "${WHITE}"
    title "CPU Performance Test - Host OS "
    show_test_cmd "[ sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --cpu-max-prime=${CPU_MAX_PRIME} --test=cpu run ]${WHITE}"
    if [ "${DRY_RUN}" != "true" ];then
      sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --cpu-max-prime=${CPU_MAX_PRIME} --test=cpu run
    fi
  fi

  if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
    echo "${GREEN}"
    title "CPU Performance Test - Docker"
    show_test_cmd  "[ docker run -t -m=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET/ /,} ${DOCKER_IMAGE} sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --cpu-max-prime=${CPU_MAX_PRIME} --test=cpu run ]${GREEN}"
    if [ "${DRY_RUN}" != "true" ];then
      docker run -t -m=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET/ /,} ${DOCKER_IMAGE} sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --cpu-max-prime=${CPU_MAX_PRIME} --test=cpu run
    fi
  fi

  if (echo "${TEST_TARGET[@]}" | grep -w "hyper" &>/dev/null);then
    echo "${BLUE}"
    title "CPU Performance Test - Hyper"
    CONTAINER_ID=$(hyper_get_container_id)
    if [ "${CONTAINER_ID}" == " " ];then
      echo "hyper container not exist, exit!" && exit 1
    fi
    show_test_cmd  "[ sudo hyper exec ${CONTAINER_ID} /usr/local/bin/sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --cpu-max-prime=${CPU_MAX_PRIME} --test=cpu run ]${BLUE}"
    if [ "${DRY_RUN}" != "true" ];then
      sudo hyper exec ${CONTAINER_ID} /usr/local/bin/sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --cpu-max-prime=${CPU_MAX_PRIME} --test=cpu run
    fi
  fi
  echo "${RESET}"
}

function do_memory_test() {
  TEST_TARGET=("$1")

  for oper in read write
  do
    for mode in seq rnd
    do
      if (echo "${TEST_TARGET[@]}" | grep -w "host" &>/dev/null);then
        echo "${WHITE}"
        title "Memory Test: $mode $oper - Host OS"
        show_test_cmd  "[ sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --test=memory --memory-oper=${oper} --memory-access-mode=${mode} run ]${WHITE}"
        if [ "${DRY_RUN}" != "true" ];then
          sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --test=memory --memory-oper=${oper} --memory-access-mode=${mode} run
        fi
      fi

      if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
        echo "${GREEN}"
        title "Memory Test: $mode $oper - Docker"
        show_test_cmd  "[ docker run -t -m=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET/ /,} ${DOCKER_IMAGE} sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --test=memory --memory-oper=${oper} --memory-access-mode=${mode} run ]${GREEN}"
        if [ "${DRY_RUN}" != "true" ];then
          docker run -t -m=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET/ /,} ${DOCKER_IMAGE} sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --test=memory --memory-oper=${oper} --memory-access-mode=${mode} run
        fi
      fi

      if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
        echo "${BLUE}"
        title "Memory Test: $mode $oper - Hyper"
        CONTAINER_ID=$(hyper_get_container_id)
        if [ "${CONTAINER_ID}" == " " ];then
          echo "hyper container not exist, exit!" && exit 1
        fi
        show_test_cmd  "[ sudo hyper exec ${CONTAINER_ID} /usr/local/bin/sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --test=memory --memory-oper=${oper} --memory-access-mode=${mode} run ]${BLUE}"
        if [ "${DRY_RUN}" != "true" ];then
          sudo hyper exec ${CONTAINER_ID} /usr/local/bin/sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --test=memory --memory-oper=${oper} --memory-access-mode=${mode} run
        fi
      fi
      echo "${RESET}"
    done
  done
}

function iotest_cmd() {
  echo "/usr/local/bin/sysbench --test=fileio prepare && /usr/local/bin/sysbench --num-threads=${NUM_THREADS} --max-requests=${MAX_REQUESTS} --file-test-mode=$1 --test=fileio run; /usr/local/bin/sysbench --test=fileio cleanup"
}

function do_io_test() {
  TEST_TARGET=("$1")

  for io_test in seqwr seqrewr seqrd rndrd rndwr rndrw
  do
    if (echo "${TEST_TARGET[@]}" | grep -w "host" &>/dev/null);then
      echo "${WHITE}"
      title "I/O Test $io_test - Host OS"
      show_test_cmd  "[ bash -c \"$(iotest_cmd $io_test)\" ]${WHITE}"
      if [ "${DRY_RUN}" != "true" ];then
        bash -c "$(iotest_cmd $io_test)"
      fi
    fi

    if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
      echo "${GREEN}"
      title "I/O Test $io_test - Docker"
      show_test_cmd  "[ docker run -t -m=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET/ /,} ${DOCKER_IMAGE} bash -c \"$(iotest_cmd $io_test)\" ]${GREEN}"
      if [ "${DRY_RUN}" != "true" ];then
        docker run -t -m=${MEMORY_SIZE}m --cpuset-cpus=${CPU_SET/ /,} ${DOCKER_IMAGE} bash -c "$(iotest_cmd $io_test)"
      fi
    fi

    if (echo "${TEST_TARGET[@]}" | grep -w "docker" &>/dev/null);then
      echo "${BLUE}"
      title "I/O Test $io_test - Hyper"
      CONTAINER_ID=$(hyper_get_container_id)
      echo "CONTAINER_ID:[$CONTAINER_ID]"
      if [ "${CONTAINER_ID}" == " " ];then
        echo "hyper container not exist, exit!" && exit 1
      fi
      show_test_cmd  "[ sudo hyper exec ${CONTAINER_ID} /bin/bash -c \"/root/test/io.sh ${NUM_THREADS} ${MAX_REQUESTS} ${io_test}\" ]${BLUE}"
      if [ "${DRY_RUN}" != "true" ];then
        sudo hyper exec ${CONTAINER_ID} /bin/bash -c "/root/test/io.sh ${NUM_THREADS} ${MAX_REQUESTS} ${io_test}"
      fi
    fi
    echo "${RESET}"
  done
}



######################################################################
# main
######################################################################
if [ $# -eq 1 ]; then
  if [ "$1" == "init" ];then
    echo "[ init ]"
    build_dockerfile
    install_sysbench
  elif [ "$1" == "clean" ];then
    clean_pod
  elif [ "$1" == "test" ]; then
    echo "[ full test ]"
    start_test "host docker hyper" "cpu mem io"
  fi
elif [ $# -eq 3 -a "$1" == "test" ]; then
  echo "[ specified test ]"
  start_test "$2" "$3"
else
  cat <<COMMENT

usage:
    ./bench.sh init
  or
    ./bench.sh clean
  or
    ./bench.sh test
  or
    ./bench.sh test "host docker hyper" "cpu mem io"

COMMENT
fi
