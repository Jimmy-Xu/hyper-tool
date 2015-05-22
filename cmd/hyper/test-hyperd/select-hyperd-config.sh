#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "select hyperd config" green

#check if hyper already exist
is_hyper_exist


CONFIG_LIST=(config-normal config-gz-s config-lz4)

echo "=============================================================================="
echo "  1 ${PURPLE}kernel(normal)${RESET}     (2.6M)"
echo "  2 ${PURPLE}kernel-gz-s${RESET}        (2.3M)  #gzip has balance decompress speed and size"
echo "  3 ${PURPLE}kernel-lz4${RESET}         (2.7M)  #lz4 is a bit bigger but decompress fast"
echo "=============================================================================="

echo -e -n "\n${BOLD}${PURPLE}Please input the ${WHITE}No.${PURPLE} of kernel${RESET}(press 'Enter' to cancel):"
read CHOICE

if [ ! -z ${CHOICE} ]
then
	VALID_CHOICE=(1 2 3)
	if echo "${VALID_CHOICE[@]}" | grep -w "${CHOICE}" &>/dev/null
	then
		NO=$((CHOICE-1))
		CONFIG_DIR=${BASE_DIR}/../../../etc
		SEL_CONFIG=${CONFIG_DIR}/${CONFIG_LIST[${NO}]}

		show_message "you select [ ${WHITE} ${CONFIG_LIST[${NO}]} ${RESET} ]" green bold

		#create link
		LINK_CURRENT=${CONFIG_DIR}/config
		if [ -f ${LINK_CURRENT} ]
		then
			show_message "link exist, will remove it first" yellow bold
			rm ${LINK_CURRENT} -rf
		fi
		ln -s ${SEL_CONFIG} ${LINK_CURRENT}

		if [ $? -eq 0 ]
		then
			#show_message "create config link succeed:) " green bold
			cd ${CONFIG_DIR}

			FOUND_CONFIG=$(ls -l --color config | grep ${CONFIG_LIST[${NO}]} | wc -l)
			if [ ${FOUND_CONFIG} -eq 1 ]
			then
				show_message "select config succeed:), current config is:" green bold
				echo "-----------------------------------------------"
				cat ${LINK_CURRENT}
				echo "-----------------------------------------------"

				echo -e -n "\n${BOLD}${PURPLE}Do you want to replace ${WHITE}/etc/dvm/config${PURPLE}? ${RESET}('y' for sure, press 'Enter' to cancel):"
				read CHOICE
				if [ ! -z ${CHOICE} -a "${CHOICE}" == "y" ]
				then
					sudo cp ${LINK_CURRENT} /etc/dvm/config
					show_message "show /etc/dvm/config" green
					cat /etc/dvm/config
				else
					show_message "cancel replace /etc/dvm/config" yellow bold
				fi

			else
				show_message "select config failed:)" red bold
			fi
		else
			show_message "create config link failed:) " red bold
		fi

	else
		show_message "valid choid is (${VALID_CHOICE[@]}), cancel"
	fi
else
	show_message "cancel"
fi


show_message "Done." green