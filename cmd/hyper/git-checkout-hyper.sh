#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../common.sh

show_message "checkout branch of hyper" green

#check GOPATH
is_gopath_exist


TARGET_DIR="${GOPATH}/src/${HYPER_CLONE_DIR}"
cd "${TARGET_DIR}"

show_message "show branches and tags in ${BLUE}${TARGET_DIR}${RESET}" green

echo -e "\n${BOLD}${CYAN}----------------- list branches ------------------${RESET}"
git branch -a

echo -e "\n${BOLD}${CYAN}------------------- list tags --------------------${RESET}"
git tag --list

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



echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}branch name / tag / commit-id ${PURPLE}${RESET}( just press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	git checkout $CHOICE
	if [ $? -eq 0 ]
	then
		show_message "check out branch to ${WHITE}${CHOICE}${GREEN} successfully:)" green bold

		echo -e "\n${BOLD}${CYAN}----------------- list branches ------------------${RESET}"
		git branch -a
	else
		show_message "check out branch to ${CHOICE} unsuccessfully:(" red bold
	fi
else
	show_message "check out branch canceled" yellow bold
fi

show_message "Done." green
