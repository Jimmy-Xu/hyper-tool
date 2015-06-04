#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "select hyperd config" green

#check if hyper already exist
is_hyper_exist


if [ $# -ne 2 ];then
	echo "parameter error, parameter should be <qboot|noqboot> <tmpfs|notmpfs>"
	exit 1
fi

QBOOT=$1
TMPFS=$2

echo "${QBOOT} + ${TMPFS}"

KERNEL_SRC=${GOPATH}/src/${HYPERINIT_CLONE_DIR}/build/kernel
INITRD_SRC=${GOPATH}/src/${HYPERINIT_CLONE_DIR}/build/hyper-initrd.img
BIOS_SRC=${BASE_DIR}/../../../boot/bios-qboot.bin
CBFS_SRC=${BASE_DIR}/../../../boot/cbfs-qboot.rom


if [ ${TMPFS} == "tmpfs" ];then
	TGT_DIR=/run/hyper
elif [ ${TMPFS} == "notmpfs" ];then
	TGT_DIR=/var/lib/hyper
fi
sudo mkdir -p ${TGT_DIR}
sudo cp ${KERNEL_SRC} ${TGT_DIR}
sudo cp ${INITRD_SRC} ${TGT_DIR}
sudo cp ${BIOS_SRC} ${TGT_DIR}
sudo cp ${CBFS_SRC} ${TGT_DIR}

if [ -f ${BASE_DIR}/../../../etc/config ];then
	show_message "remove old config"
	\rm -rf ${BASE_DIR}/../../../etc/config
fi

echo "Kernel=${TGT_DIR}/kernel" > ${BASE_DIR}/../../../etc/config
echo "Initrd=${TGT_DIR}/hyper-initrd.img" >> ${BASE_DIR}/../../../etc/config

if [ ${QBOOT} == "qboot" ];then
	echo "Bios=${TGT_DIR}/bios-qboot.bin" >> ${BASE_DIR}/../../../etc/config
	echo "Cbfs=${TGT_DIR}/cbfs-qboot.rom" >> ${BASE_DIR}/../../../etc/config
elif [ ${QBOOT} == "noqboot" ];then
	echo "#Bios=${TGT_DIR}/bios-qboot.bin" >> ${BASE_DIR}/../../../etc/config
	echo "#Cbfs=${TGT_DIR}/cbfs-qboot.rom" >> ${BASE_DIR}/../../../etc/config
fi

show_message "new config file: ${BASE_DIR}/../../../etc/config" green
echo "-- config file content -------------------------------------"
cat ${BASE_DIR}/../../../etc/config

show_message "kernel, initrd, bios and rom under ${TGT_DIR}" green
echo "------------------------------------------------------------"
if [ ${QBOOT} == "qboot" ];then
	ls -l --color ${TGT_DIR}/{kernel,hyper-initrd.img,bios-qboot.bin,cbfs-qboot.rom}
else
	ls -l --color ${TGT_DIR}/{kernel,hyper-initrd.img}
fi

if [ $? -eq 0 ];then
	show_message "select config succeed!" green
else
	show_message "select config failed!" red
fi

show_message "Done." green