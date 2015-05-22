#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "put /var/lib/dvm/{cbfs.rom,bios.bin} to /var/run/dvm/" green

show_message "check source file" green
ls /var/lib/dvm/{cbfs.rom,bios.bin}
if [ $? -ne 0 ]
then
	show_message "there is no /var/lib/dvm/{cbfs.rom,bios.bin}, please install hyper first:(" red bold
	exit 1
fi

show_message "start copy file" green
sudo cp /var/lib/dvm/{cbfs.rom,bios.bin} /var/run/dvm/

sudo ls -l --color /var/run/dvm/{cbfs.rom,bios.bin}
if [ $? -eq 0 ]
then
	show_message "cbfs.rom & bios.bin are under /var/run/dvm/ now :)" green bold
else
	show_message "there is no {cbfs.rom,bios.bin} under /var/run/dvm/ :(" red bold
fi

show_message "Done." green
