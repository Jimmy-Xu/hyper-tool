#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "clear test env( pod & qemu process )" green bold

#check hyper dir
is_hyper_exist

#check hyperd process
is_hyperd_running


cd "${GOPATH}/src/${HYPER_CLONE_DIR}"
sudo echo



show_message "stop all running pod" green bold
sudo ./hyper list pod | grep "pod-.*running" | awk '{print $1}' | xargs -i sudo ./hyper stop pod {}

show_message "remove all created pod" green bold
sudo ./hyper list | grep "pod-.*created" | awk '{print $1}' | xargs -i sudo ./hyper rm {}

show_message "kill qemu" green bold
pkill qemu


echo -e "\n${BOLD}${YELLOW}===================================================="
echo " check evn again :"
echo "====================================================${RESET}"

echo -e -n "${BOLD}${WHITE} container(s)     : ${RESET}${PURPLE}"
sudo ./hyper list container | grep online | wc -l

echo -e -n "${BOLD}${WHITE} running pod(s)   : ${RESET}${PURPLE}"
sudo ./hyper list | grep running | grep -v ERROR | wc -l

echo -e -n "${BOLD}${WHITE} stopped pod(s)   : ${RESET}${PURPLE}"
sudo ./hyper list | grep created | wc -l

echo -e -n "${BOLD}${WHITE} all pod(s)       : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-" | wc -l

echo -e -n "${BOLD}${WHITE} qemu process(es) : ${RESET}${PURPLE}"
sudo pgrep qemu | wc -l

echo -e -n "${BOLD}${WHITE} tap device(s)    : ${RESET}${PURPLE}"
sudo ifconfig | grep "^tap" | wc -l

echo "${RESET}"


show_message "Done." green bold