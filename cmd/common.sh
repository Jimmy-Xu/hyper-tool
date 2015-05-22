#!/bin/bash

###################################################
# variable(customizable)
###################################################

#for hyper repo
HYPER_REPO="git@github.com:getdvm/dvm-cli.git"
HYPER_CLONE_DIR="dvm"

#for hyperinit repo
HYPERINIT_REPO="git@github.com:getdvm/dvminit.git"
HYPERINIT_CLONE_DIR="dvminit"

#for golang
GOROOT_DIR=~/go
GOPATH_DIR=~/gopath
#golang filename
GOLANG=go1.4.2.linux-amd64
GOLANG_URL=https://storage.googleapis.com/golang/${GOLANG}.tar.gz

#kernel in tmpfs
HYPER_KERNEL_DIR=/run/hyper-kernel

QEMU_PROCESS=qemu-system-x86_64

###################################################
# function
###################################################
#pause
function pause() {
  read -n 1 -p "${LEFT_PAD}${BLUE}Press any key to continue...${RESET}"
}

#check GOPATH before clone hyper and hyperinit
function is_gopath_exist() {
	if [ -z $GOPATH ]
	then
	  echo -e "\nplease set env GOPATH first!"
	  exit 1
	fi
}

#check GOPATH and go before build hyper and hyperinit
function is_go_exist() {
	if [ -z $GOROOT ]
	then
	  echo -e "\nplease set env GOROOT first!"
	  exit 1
	fi

	INST_GO=$(which go 2>/dev/null)
	if [ $? -ne 0 ]
	then
		echo -e "\nplease install golang first!"
		exit 1
	fi
}

#check GOPATH before clone hyper and hyperinit
function is_tar_gz_valid() {
	TAR_FILE=$1

	if [ $# -eq 0 ]
	then
		echo -e "\nno file to check,cancel\n"
		exit 1
	fi

	if [ ! -f "${TAR_FILE}" ]
	then
		echo -e "\ncan not found file ${TAR_FILE},cancel\n"
		exit 1
	fi

	tar ztvf "${TAR_FILE}" > /dev/null
	if [ $? -ne 0 ]
	then
		echo -e "\nfile ${TAR_FILE} is bad! remove now\n"
		rm ${TAR_FILE}
	fi
}


#show local hyper repo info
function show_repo_info() {
	TARGET_DIR=$1
	if [ -d "${TARGET_DIR}" ]
	then
		cd "${TARGET_DIR}"


		show_message "show repo info in ${BLUE}${TARGET_DIR}${RESET}" green

		echo -e "\n${BOLD}${CYAN}------------------- list files -------------------${RESET}"
		ls -l --color

		echo -e "\n${BOLD}${CYAN}----------------- list branches ------------------${RESET}"
		git branch -a

		echo -e "\n${BOLD}${CYAN}------------------- list tags --------------------${RESET}"
		git tag --list

		echo -e "\n${BOLD}${CYAN}------------------ show status -------------------${RESET}"
		git status

		echo -e "\n${BOLD}${CYAN}-------------------- git lg ----------------------${RESET}"
		#ensure local alias.lg
		git config --list | grep "alias.log" > /dev/null || git config alias.lg "log --graph --pretty=format:'[%ci] %Cgreen(%cr) %Cred%h%Creset -%x09%C(yellow)%Creset %C(cyan)[%an]%Creset %x09 %s %Cgreen(%cr)%Creset' --abbrev-commit --date=short"
		#show git log
		LOG_LEN=$(git lg --since=yesterday | wc -l)
		if [ ${LOG_LEN} -eq 0 ]
		then
			git lg | head -n 20
		else
			git lg --after="yesterday" | head -n 20
		fi
		echo -e "\n..."

		echo -e "${BOLD}${CYAN}====================================================================================================${RESET}"

		REPO_URL=$(git config --list | grep "remote.origin.url" | cut -d"=" -f2)
		echo "${WHITE}#######################################################"
		echo " remote repo url: [ ${PURPLE}${REPO_URL}${WHITE} ]"
		echo " local repo info: [ ${PURPLE}${TARGET_DIR}${WHITE} ]"
		echo "#######################################################${RESET}"
	fi
}

#check if hyper is cloned to local
function is_hyper_exist() {
	if [ ! -d "$GOPATH/src/${HYPER_CLONE_DIR}" ]
	then
		show_message "$GOPATH/src/${HYPER_CLONE_DIR} doesn't exist! please clone it first!" red bold
		exit 1
	fi
}

#check if hyperinit is cloned to local
function is_hyperinit_exist() {
	if [ ! -d "$GOPATH/src/${HYPERINIT_CLONE_DIR}" ]
	then
		show_message "$GOPATH/src/${HYPERINIT_CLONE_DIR} doesn't exist! please clone it first!" red bold
		exit 1
	fi
}

#show local hyper repo info
function show_hyper_info() {
	is_hyper_exist
	TARGET_DIR="$GOPATH/src/${HYPER_CLONE_DIR}"
	show_repo_info "${TARGET_DIR}"
}

#show local hyperinit repo info
function show_hyperinit_info() {
	is_hyperinit_exist
	TARGET_DIR="$GOPATH/src/${HYPERINIT_CLONE_DIR}"
	show_repo_info "${TARGET_DIR}"
}



#check if hyper is cloned to local
function is_docker_installed() {
	INST_DOCKER=$(which docker 2>/dev/null)
	if [ $? -eq 0 ]
	then
		show_message "Docker version:" purple
		sudo docker --version
	else
		show_message "docker hasn't been installed, please install docker first." yellow bold
		exit 1
	fi

}


#check if golang is installed
function is_golang_installed() {
	INST_GO=$(which go 2>/dev/null)
	if [ $? -eq 0 ]
	then
		show_message "go version:" purple
		go version
	else
		show_message "golang hasn't been installed, please install golang first." yellow bold
		exit 1
	fi

}


#check if qemu is installed
function is_qemu_installed() {
	INST_QEMU=$(which ${QEMU_PROCESS} 2>/dev/null)
	if [ $? -eq 0 ]
	then
		show_message "qemu version:" purple
		${QEMU_PROCESS} --version
	else
		show_message "qemu hasn't been installed, please install qemu first." yellow bold
		exit 1
	fi

}

#check if hyper is cloned to local
function is_hyperd_running() {
	pgrep hyperd >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		show_message "hyperd is running:)" green
	else
		show_message "hyperd isn't running:(" red bold
		exit 1
	fi
}

#check if hyper is cloned to local
function is_hyper_cli_installed() {
	which hyper
	if [ $? -eq 0 ]
	then
		show_message "hyper client is installed:)" green
		hyper version
	else
		show_message "hyper client isn't installed:(" red bold
		exit 1
	fi
}


function is_sysbench_installed() {
	which sysbench
	if [ $? -eq 0 ]
	then
		show_message "sysbench is installed:)" green
		sysbench --version
	else
		show_message "sysbench isn't installed:(" red bold
		exit 1
	fi
}

function get_os_distro(){

	SUPPORT_OS_TYPE=(Linux MINGW32)
	SUPPORT_OS_DISTRO=(Ubuntu)

	UNAME=$(uname -a | awk 'BEGIN{FS="[_ ]"}{print $1}')
	if echo "${SUPPORT_OS_TYPE[@]}" | grep -w "${UNAME}" &>/dev/null
	then
		if [ "${UNAME}" == "Linux" ]
		then
			if [ -f /usr/bin/lsb_release ]
			then
				OS_DISTRO=$(/usr/bin/lsb_release -a 2>/dev/null| grep "Distributor ID" | awk '{print $3}')
			else
				OS_DISTRO=$(cat /etc/issue |sed -n '1p' | awk '{print $1}')
			fi
			if echo "${SUPPORT_OS_DISTRO[@]}" | grep -w "${OS_DISTRO}" &>/dev/null
			then
				echo "${OS_DISTRO}"
			else
				echo "hyper-tool only support OS_DISTRO [${SUPPORT_OS_TYPE[@]}], doesn't support ${OS_DISTRO} "
				exit 1
			fi
		elif [ "${UNAME}" == "MINGW32" ]
		then
			OS_DISTRO="Windows"
			echo "${OS_DISTRO}"

		fi
	else
		echo "hyper-tool only support OS_TYPE [${SUPPORT_OS_TYPE[@]}], doesn't support ${UNAME} "
		exit 1
	fi
}



###################################################
#show color message
#format: "show_message <message> [color]"
function show_message() {
    local message="$1";
    local color=$2;
    local bold=$3;
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        purple) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    if [ ! -z $bold ]
    then
    	tput bold
	fi
    tput setaf $color;
    echo -e "\n> ${message}";
    tput sgr0;
}

# color
BLACK=`tput setaf 0`
RED=`tput setaf 1`     #error
GREEN=`tput setaf 2`   #info
YELLOW=`tput setaf 3`  #warning
BLUE=`tput setaf 4`
PURPLE=`tput setaf 5`  #prompt
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`
RESET=`tput sgr0`
BOLD=`tput bold `
#example
#echo "Dark : ${BLACK}black ${RED}red ${GREEN}green ${YELLOW}yellow ${BLUE}blue ${PURPLE}purple ${CYAN}cyan ${WHITE}white ${RESET}"
#echo "Ligth: ${BOLD} ${BLACK}black ${RED}red ${GREEN}green ${YELLOW}yellow ${BLUE}blue ${PURPLE}purple ${CYAN}cyan ${WHITE}white ${RESET}"

