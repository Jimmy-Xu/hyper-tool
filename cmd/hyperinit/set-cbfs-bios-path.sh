#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "set cbfs.rom to ${BLUE}/var/lib/dvm/${GREEN} or ${BLUE}/var/run/dvm/${GREEN}" green

show_message "check source file" green
ls /var/lib/dvm/cbfs.rom
if [ $? -ne 0 ]
then
	show_message "there is no /var/lib/dvm/cbfs.rom, please install hyper first:(" red bold
	exit 1
fi


echo -e -n "\n${BOLD}${PURPLE}Which path do you want put ${WHITE}cbfs.rom${PURPLE} in?${RESET}('1' for ${BLUE}/var/lib/dvm/${WHITE}(RESET), '2' for ${BLUE}/var/run/dvm/${RESET} ,press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	if [ "${CHOICE}" -eq 2 ]
	then
		show_message "start copy file /var/lib/dvm/cbfs.rom to ${BLUE}/var/run/dvm/${GREEN}" green
		sudo cp /var/lib/dvm/cbfs.rom /var/run/dvm/

		sudo ls -l --color /var/run/dvm/cbfs.rom
		if [ $? -eq 0 ]
		then
			show_message "cbfs.rom are under ${BLUE}/var/run/dvm/${GREEN} now :)" green bold
		else
			show_message "there is no cbfs.rom under ${BLUE}/var/run/dvm/${RED} :(" red bold
		fi
	elif [ "${CHOICE}" -eq 1 ]
	then
		show_message "start remove /var/run/dvm/cbfs.rom" green
		sudo rm /var/run/dvm/cbfs.rom -rf

		sudo ls -l --color /var/run/dvm/cbfs.rom
		if [ $? -eq 0 ]
		then
			show_message "remove /var/run/dvm/cbfs.rom failed :(" red bold
		else
			show_message "there is no cbfs.rom under ${BLUE}/var/run/dvm/${GREEN} now :)" green bold
		fi
	else
		show_message "valid input is 1 or 2, '${CHOICE}' is invalid" yellow bold
	fi
else
	show_message "cancel" yellow
fi

show_message "ensure there is no bios.bin under ${BLUE}/var/lib/dvm/${GREEN} and ${BLUE}/var/run/dvm${GREEN}" green bold
if [ -f /var/lib/dvm/bios.bin ]
then
	sudo rm /var/lib/dvm/bios.bin
fi
if [ -f /var/run/dvm/bios.bin ]
then
	sudo rm /var/run/dvm/bios.bin
fi

show_message "Done." green
