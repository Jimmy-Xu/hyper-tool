#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "put kernel to tmpfs" green bold

echo
echo "[Source] : ${PURPLE}$GOPATH/src/${HYPERINIT_CLONE_DIR}/test/{kernel,initrd-dvm.img}${RESET}"
echo "[Target] : ${PURPLE}${HYPER_KERNEL_DIR}${RESET}"
echo

cd "$GOPATH/src/${HYPERINIT_CLONE_DIR}"
if [ -f test/kernel -a -f test/initrd-dvm.img ]
then
	if [ ! -d "${HYPER_KERNEL_DIR}" ]
	then
		#create HYPER_KERNEL_DIR if not exist
		show_message "creating ${HYPER_KERNEL_DIR}" green bold
		sudo mkdir -p ${HYPER_KERNEL_DIR}
		if [ $? -ne 0 ]
		then
			show_message "Can not create [ ${HYPER_KERNEL_DIR} ]" red bold
			exit 1
		fi
	else
		echo "${BOLD}${YELLOW}[ ${PURPLE}${HYPER_KERNEL_DIR}${RESET} ] already exist, no need create dir!${RESET}"
	fi

	#HYPER_KERNEL_DIR existed
	show_message "copying kernel and initrd-dvm.img to tmpfs[${HYPER_KERNEL_DIR}]" green bold
	sudo cp "$GOPATH/src/${HYPERINIT_CLONE_DIR}"/test/{kernel,initrd-dvm.img} "${HYPER_KERNEL_DIR}"

	if [ -d "${BASE_DIR}/../../kernel" ]
	then
		show_message "copying minified kernel to tmpfs[${HYPER_KERNEL_DIR}]" green bold
		sudo cp ${BASE_DIR}/../../kernel/kernel* "${HYPER_KERNEL_DIR}"
	fi

	echo
	echo "${BOLD}${YELLOW}=================================="
	echo "list file in [ ${PURPLE}${HYPER_KERNEL_DIR}${YELLOW} ]:"
	echo "==================================${RESET}"
	ls -l --color ${HYPER_KERNEL_DIR}

else
	show_message "kernel and initrd-dvm.img not exist in dir [$GOPATH/src/${HYPERINIT_CLONE_DIR}" red bold
fi


show_message "Done." green bold
