#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "set {cbfs.rom,bios.bin} to ${BLUE}/var/lib/dvm/${GREEN} or ${BLUE}/var/run/dvm/${GREEN}" green

show_message "check source file" green
ls /var/lib/dvm/{cbfs.rom,bios.bin}
if [ $? -ne 0 ]
then
	show_message "there is no /var/lib/dvm/{cbfs.rom,bios.bin}, please install hyper first:(" red bold
	exit 1
fi


echo -e -n "\n${BOLD}${PURPLE}Which path do you want put ${WHITE}{cbfs.rom,bios.bin}${PURPLE} in?${RESET}('1' for ${BLUE}/var/lib/dvm/${WHITE}(RESET), '2' for ${BLUE}/var/run/dvm/${RESET} ,press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	if [ "${CHOICE}" -eq 2 ]
	then
		show_message "start copy file /var/lib/dvm/{cbfs.rom,bios.bin} to ${BLUE}/var/run/dvm/${GREEN}" green
		sudo cp /var/lib/dvm/{cbfs.rom,bios.bin} /var/run/dvm/

		sudo ls -l --color /var/run/dvm/{cbfs.rom,bios.bin}
		if [ $? -eq 0 ]
		then
			show_message "cbfs.rom & bios.bin are under ${BLUE}/var/run/dvm/${GREEN} now :)" green bold
		else
			show_message "there is no {cbfs.rom,bios.bin} under ${BLUE}/var/run/dvm/${RED} :(" red bold
		fi
	elif [ "${CHOICE}" -eq 1 ]
	then
		show_message "start remove /var/run/dvm/{cbfs.rom,bios.bin}" green
		sudo rm /var/run/dvm/{cbfs.rom,bios.bin} -rf

		sudo ls -l --color /var/run/dvm/{cbfs.rom,bios.bin}
		if [ $? -eq 0 ]
		then
			show_message "remove /var/run/dvm/{cbfs.rom,bios.bin} failed :(" red bold
		else
			show_message "there is no cbfs.rom & bios.bin under ${BLUE}/var/run/dvm/${GREEN} now :)" green bold
		fi
	else
		show_message "valid input is 1 or 2, '${CHOICE}' is invalid" yellow bold
	fi
else
	show_message "cancel" yellow
fi

show_message "Done." green
