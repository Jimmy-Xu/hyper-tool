#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "clear test env( pod & qemu process )" green

#check hyper dir
is_hyper_exist

#check hyperd process
is_hyperd_running


cd "${GOPATH}/src/${HYPER_CLONE_DIR}"
sudo echo


NUM_RUNNING_POD=$(sudo ./hyper list pod | grep "pod-.*running" | wc -l)
show_message "stop all running pod: ( ${PURPLE}${NUM_RUNNING_POD}${GREEN} )" green
sudo ./hyper list pod | grep "pod-.*running" | awk '{print $1}' | xargs -i sudo ./hyper stop {}
sleep 1

NUM_CREATED_POD=$(sudo ./hyper list pod | grep "pod-.*created" | wc -l)
show_message "remove all created pod: ( ${PURPLE}${NUM_CREATED_POD}${GREEN} )" green
sudo ./hyper list pod | grep "pod-.*created" | awk '{print $1}' | xargs -i sudo ./hyper rm {}

sleep 1
NUM_QEMU_PROCESS=$(pgrep qemu| wc -l)
show_message "kill all qemu process: ( ${PURPLE}${NUM_QEMU_PROCESS}${GREEN} )" green
sudo pkill qemu
sleep 1

echo -e "\n${BOLD}${CYAN}===================================================="
echo " check evn again :"
echo "====================================================${RESET}"

echo -e -n "${BOLD}${WHITE} containers     : ${RESET}${PURPLE}"
sudo ./hyper list container | grep online | wc -l

echo -e -n "${BOLD}${WHITE} running pods   : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*running" | grep -v ERROR | wc -l

echo -e -n "${BOLD}${WHITE} stopped pods   : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*created" | wc -l

echo -e -n "${BOLD}${WHITE} all pods       : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-" | wc -l

echo -e -n "${BOLD}${WHITE} qemu processes : ${RESET}${PURPLE}"
sudo pgrep qemu | wc -l

echo -e -n "${BOLD}${WHITE} tap devices    : ${RESET}${PURPLE}"
sudo ifconfig | grep "^tap" | wc -l

echo "${RESET}"


show_message "Done." green