#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "check test env" green

#check hyper dir
is_hyper_exist

#check hyperd process
is_hyperd_running


cd "${GOPATH}/src/${HYPER_CLONE_DIR}"
sudo echo

echo -e "${BOLD}${CYAN}===================================================="
echo " check result :"
echo "====================================================${RESET}"

echo -e -n "${BOLD}${WHITE} containers              : ${RESET}${PURPLE}"
sudo ./hyper list container | grep online | wc -l

echo -e -n "${BOLD}${WHITE} running pods            : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*running" | grep -v ERROR | wc -l

echo -e -n "${BOLD}${WHITE} stopped(pending) pods   : ${RESET}${PURPLE}"
sudo ./hyper list | grep -E "pod-.*pending" | wc -l

echo -e -n "${BOLD}${WHITE} stopped(succeeded) pods : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*succeeded" | wc -l

echo -e -n "${BOLD}${WHITE} all pods                : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*" | wc -l

echo -e -n "${BOLD}${WHITE} qemu processes          : ${RESET}${PURPLE}"
sudo pgrep qemu | wc -l

echo -e -n "${BOLD}${WHITE} tap devices             : ${RESET}${PURPLE}"
sudo ifconfig | grep "^tap" | wc -l

echo "${RESET}"


show_message "Done." green