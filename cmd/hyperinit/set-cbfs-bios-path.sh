#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "set cbfs.rom to ${BLUE}/var/lib/hyper/${GREEN} or ${BLUE}/var/run/hyper/${GREEN}" green

show_message "check source file" green
ls /var/lib/hyper/cbfs.rom
if [ $? -ne 0 ]
then
	show_message "there is no /var/lib/hyper/cbfs.rom, please install hyper first:(" red bold
	exit 1
fi


echo -e -n "\n${BOLD}${PURPLE}Which path do you want put ${WHITE}cbfs.rom${PURPLE} in?${RESET}('1' for ${BLUE}/var/lib/hyper/${WHITE}(RESET), '2' for ${BLUE}/var/run/hyper/${RESET} ,press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	if [ "${CHOICE}" -eq 2 ]
	then
		show_message "start copy file /var/lib/hyper/cbfs.rom to ${BLUE}/var/run/hyper/${GREEN}" green
		sudo cp /var/lib/hyper/cbfs.rom /var/run/hyper/

		sudo ls -l --color /var/run/hyper/cbfs.rom
		if [ $? -eq 0 ]
		then
			show_message "cbfs.rom are under ${BLUE}/var/run/hyper/${GREEN} now :)" green bold
		else
			show_message "there is no cbfs.rom under ${BLUE}/var/run/hyper/${RED} :(" red bold
		fi
	elif [ "${CHOICE}" -eq 1 ]
	then
		show_message "start remove /var/run/hyper/cbfs.rom" green
		sudo rm /var/run/hyper/cbfs.rom -rf

		sudo ls -l --color /var/run/hyper/cbfs.rom
		if [ $? -eq 0 ]
		then
			show_message "remove /var/run/hyper/cbfs.rom failed :(" red bold
		else
			show_message "there is no cbfs.rom under ${BLUE}/var/run/hyper/${GREEN} now :)" green bold
		fi
	else
		show_message "valid input is 1 or 2, '${CHOICE}' is invalid" yellow bold
	fi
else
	show_message "cancel" yellow
fi

show_message "ensure there is no bios.bin under ${BLUE}/var/lib/hyper/${GREEN} and ${BLUE}/var/run/hyper${GREEN}" green bold
if [ -f /var/lib/hyper/bios-qboot.bin ]
then
	sudo rm /var/lib/hyper/bios-qboot.bin
fi
if [ -f /var/run/hyper/bios-qboot.bin ]
then
	sudo rm /var/run/hyper/bios-qboot.bin
fi

show_message "Done." green
