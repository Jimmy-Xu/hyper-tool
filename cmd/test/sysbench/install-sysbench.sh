#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh


show_message "install sysbench" green

show_message "install dependency" green
sudo apt-get install -y bzr automake autoconf make libtool


show_message "download sysbench-0.5 source by bzr" green
cd ~
echo "Current dir : ${BLUE}$(pwd)${RESET}"
bzr branch lp:~sysbench-developers/sysbench/0.5  sysbench-0.5


if [ -d ~/sysbench-0.5 ]
then
	show_message "build & install sysbench-0.5 from source" green
	cd sysbench-0.5
	./autogen.sh
	if [ $? -eq 0 ]
	then
		./configure --without-mysql
		if [ $? -eq 0 ]
		then
			make
			if [ $? -eq 0 ]
			then
				sudo make install
				if [ $? -eq 0 ]
				then
					show_message "build and install sysbench-0.5 succeed:)" green bold
				else
					show_message "make install failed:(" red bold
				fi
			else
				show_message "make failed:(" red bold
			fi
		else
			show_message "./configure failed:(" red bold
		fi
	else
		show_message "./autogen.sh failed:(" red bold
	fi

	#check if sysbench installed
	is_sysbench_installed
else
	show_message "~/sysbench-0.5 not exist, download by bzr failed:(" red bold
fi

show_message "Done." green
