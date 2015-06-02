#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "build hyperinit" green

#check if hyper already exist
is_hyperinit_exist

#main
cd "$GOPATH/src/${HYPERINIT_CLONE_DIR}"
echo "current dir is: [ ${BOLD}${BLUE}`pwd`${RESET} ]"


#execute result
UNEXECUTED="${BLACK}unexecuted${RESET}"
SUCCESS="${GREEN}success${RESET}"
FAIL="${RED}fail${RESET}"

AUTOGEN_OK="${UNEXECUTED}"
CONFIGURE_OK="${UNEXECUTED}"
MAKE_OK="${UNEXECUTED}"
COMPRESS_OK="${UNEXECUTED}"

#start execute
if [ -f ./autogen.sh ]
then
	show_message "[Step 1] start auto generate configure and make" green
	./autogen.sh
	if [ $? -eq 0 ]
	then
		#autogen.sh succeed
		AUTOGEN_OK="${SUCCESS}"
		if [ -f ./configure ]
		then
			show_message "[Step 2] start execute ./configure" green
			./configure
			if [ $? -eq 0 ]
			then
				#configure succeed
				CONFIGURE_OK="${SUCCESS}"
				if [ -f ./Makefile ]
				then
					show_message "[Step 3] start execute make" green
					make
					if [ $? -eq 0 ]
					then
						MAKE_OK="${SUCCESS}"
					else
						MAKE_OK="${FAIL}"
					fi
				fi
			else
				CONFIGURE_OK="${FAIL}"
			fi
		else
			AUTOGEN_OK="${FAIL}"
		fi
	fi
fi


#show result
echo
echo "${BOLD}${YELLOW}=================================="
echo "build result:"
echo "==================================${RESET}"
echo "[Step 1] ./autogen.sh    => ${AUTOGEN_OK}"
echo "[Step 2] ./configure     => ${CONFIGURE_OK}"
echo "[Step 3] ./make          => ${MAKE_OK}"
echo
echo "${BOLD}${YELLOW}=================================="
echo "list result:"
echo "==================================${RESET}"
cd "$GOPATH/src/${HYPERINIT_CLONE_DIR}"
ls -l --color build/{kernel,hyper-initrd.img}
echo


show_message "Done." green
