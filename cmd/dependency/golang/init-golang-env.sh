#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "set env for go" green

##################################################
#~/.bashrc
##################################################
# export GOROOT=~/go
# export GOPATH=~/gopath
# export GOOS=linux
# export GOARCH=amd64
# export PATH=${GOROOT}/bin:${GOPATH}/bin:${PATH}
##################################################

BASHRC=~/.bashrc

echo "Start write go env to ${BASHRC}"
#grep "^export GOOS="   "${BASHRC}" > /dev/null ||  echo "export GOOS=linux"      >> "${BASHRC}"
#grep "^export GOARCH"  "${BASHRC}" > /dev/null ||  echo "export GOARCH=amd64"    >> "${BASHRC}"
grep "^export GOROOT=" "${BASHRC}" > /dev/null ||  echo "export GOROOT=${GOROOT_DIR}" >> "${BASHRC}"
grep "^export GOPATH=" "${BASHRC}" > /dev/null ||  echo "export GOPATH=${GOPATH_DIR}" >> "${BASHRC}"
grep "^export PATH=\${GOROOT}" "${BASHRC}" > /dev/null || echo "export PATH=\${GOROOT}/bin:\${GOPATH}/bin:\${PATH}" >> "${BASHRC}"

echo -e "\n${BOLD}${CYAN}------------------ show go env ---------------------${RESET}"
grep -E "(^export GOROOT=|^export GOPATH=|^export GOOS=|^export GOARCH)" "${BASHRC}"
grep "^export PATH=\${GOROOT}" "${BASHRC}"
echo -e "\n-------------------------------------------------------------------------------"
echo "${BOLD}${PURPLE}Run 'source ~/.bashrc' after modify  ~/.bashrc, then run ./hyper-tool.sh again ${RESET}"
echo "-------------------------------------------------------------------------------"

#create dir $GOPATH/src
. ~/.bashrc
mkdir -p ${GOPATH_DIR}/src

show_message "Done." green
