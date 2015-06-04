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

NUM_PENDING_POD=$(sudo ./hyper list pod | grep "pod-.*pending" | wc -l)
show_message "remove all stopped(pending) pod: ( ${PURPLE}${NUM_PENDING_POD}${GREEN} )" green
sudo ./hyper list pod | grep "pod-.*pending" | awk '{print $1}' | xargs -i sudo ./hyper rm {}

NUM_PENDING_POD=$(sudo ./hyper list pod | grep "pod-.*succeeded" | wc -l)
show_message "remove all stopped(succeeded) pod: ( ${PURPLE}${NUM_PENDING_POD}${GREEN} )" green
sudo ./hyper list pod | grep "pod-.*succeeded" | awk '{print $1}' | xargs -i sudo ./hyper rm {}

sleep 1
NUM_QEMU_PROCESS=$(pgrep qemu| wc -l)
show_message "kill all qemu process: ( ${PURPLE}${NUM_QEMU_PROCESS}${GREEN} )" green
sudo pkill qemu
sleep 1

echo -e "\n${BOLD}${CYAN}===================================================="
echo " check evn again :"
echo "====================================================${RESET}"

echo -e -n "${BOLD}${WHITE} containers              : ${RESET}${PURPLE}"
sudo ./hyper list container | grep online | wc -l

echo -e -n "${BOLD}${WHITE} running pods            : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*running" | grep -v ERROR | wc -l

echo -e -n "${BOLD}${WHITE} stopped(pending) pods   : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*pending" | wc -l

echo -e -n "${BOLD}${WHITE} stopped(succeeded) pods : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-.*succeeded" | wc -l

echo -e -n "${BOLD}${WHITE} all pods                : ${RESET}${PURPLE}"
sudo ./hyper list | grep "pod-" | wc -l

echo -e -n "${BOLD}${WHITE} qemu processes          : ${RESET}${PURPLE}"
sudo pgrep qemu | wc -l

echo -e -n "${BOLD}${WHITE} tap devices             : ${RESET}${PURPLE}"
sudo ifconfig | grep "^tap" | wc -l

echo "${RESET}"


show_message "Done." green