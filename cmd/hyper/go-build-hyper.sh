#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "build hyper and hyperd" green bold

#check GOROOT and go
is_go_exist


#check if hyper already exist
is_hyper_exist

#execute result
SUCCESS="${GREEN}success${RESET}"
FAIL="${RED}fail${RESET}"

#main
cd "$GOPATH/src/${HYPER_CLONE_DIR}"
if [ -f hyperd.go -a -f hyper.go ]
then
	show_message "[Step 1] build hyper.go" green bold
	go build hyper.go
	if [ $? -eq 0 ]
	then
		RLT_BLT_HYPER="${SUCCESS}"
	else
		RLT_BLT_HYPER="${FAIL}"
	fi

	show_message "[Step 2] build hyperd.go" green bold
	go build hyperd.go
	if [ $? -eq 0 ]
	then
		RLT_BLT_HYPERD="${SUCCESS}"
	else
		RLT_BLT_HYPERD="${FAIL}"
	fi

	echo -e "\n${BOLD}${YELLOW}Build result:${RESET}"
	echo "------------------------------"
	echo "hyper  : ${RLT_BLT_HYPER}"
	echo "hyperd : ${RLT_BLT_HYPERD}"

	echo -e "\n${BOLD}${YELLOW}List build result:${RESET}"
	echo "------------------------------------------------------------"
	ls -l --color hyper hyperd
	echo "------------------------------------------------------------"


fi

show_message "Done." green bold