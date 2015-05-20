#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
. ${BASE_DIR}/../../common.sh

show_message "update hyperd config" green


#check if hyper already exist
is_hyper_exist


show_message "Done." green