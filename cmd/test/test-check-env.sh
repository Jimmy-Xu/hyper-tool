#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "test pod startup time" green bold

#check hyper dir
is_hyper_exist

#check hyperd process
is_hyperd_running


cd "${GOPATH}/src/${HYPER_CLONE_DIR}"
sudo echo

echo -e "${BOLD}${YELLOW}===================================================="
echo " check result :"
echo "====================================================${RESET}"

echo -e -n "${BOLD}${WHITE} container(s)     : ${RESET}${PURPLE}"
sudo ./hyper list container | grep online | wc -l

echo -e -n "${BOLD}${WHITE} running pod(s)   : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*running" | grep -v ERROR | wc -l

echo -e -n "${BOLD}${WHITE} stopped pod(s)   : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*created" | wc -l

echo -e -n "${BOLD}${WHITE} all pod(s)       : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*" | wc -l

echo -e -n "${BOLD}${WHITE} qemu process(es) : ${RESET}${PURPLE}"
sudo pgrep qemu | wc -l

echo -e -n "${BOLD}${WHITE} tap device(s)    : ${RESET}${PURPLE}"
sudo ifconfig | grep "^tap" | wc -l

echo "${RESET}"


show_message "Done." green bold