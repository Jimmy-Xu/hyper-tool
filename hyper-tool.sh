#!/bin/bash

#***************************************************
# Created date: 2015/05/16
# Filename:   dvm-tool.sh
# Description:  generate tool.sh by etc/menu.conf
# Comment: 1. support multiple level menu 2. max menuitem of each level is 9
# --------------------------------------------------
# MENUITEM config parameter description
#  MI_TYPE   => menuitem type : config_file | shell_script | exit | return
#  MI_NAME   => id of menuitem
#  MI_ITEM   => menuitem display name
#  MI_DESC   => menuitem description
#  MI_SPLIT  => splitter type(before current menuitem) : ""->no splitter,  "blank"->blank line,  "single"->THIN_LINE, "double"->THICK_LINE
#  MI_CONFIRM=> need confirm before execute script
# --------------------------------------------------
# Creater: Jimmy Xu
#****************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
#****************************************************


#########################################################################
#include common.sh
. cmd/common.sh


#########################################################################
# Constant Declaration
#########################################################################
#ansi color
B_TAG="\033"
E_TAG="\033[0m"
white="37"
black="40"
Ht="[7"
Bt="${B_TAG}${Ht};${white};${black}m"
Et="${E_TAG}"


THIN_LINE=" ───  ───────────────────────────────────  ──────────────────────────────────────────────"
THICK_LINE=" ━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LEFT_PAD="  "

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
LOG_FILE="${BASE_DIR}/log/hyper-tool.log"
mkdir -p ${BASE_DIR}/log
touch "${LOG_FILE}"

JQ="jq"
UNAME=$(uname -a | awk 'BEGIN{FS="[_ ]"}{print $1}')
if [ "${UNAME}" == "MINGW32" ]
then
  JQ="jq.exe"
fi

#########################################################################
# Function Declaration
#########################################################################

###################################################
#line move for decorating
function lineMove() {
  clear
  echo
}

###################################################
# output log to ${LOG_FILE}
function log_message(){
  lvl=${1:-u}
  msg=$2
  case $lvl in
    i) level="INFO:    "
    ;;
    w) level="WARNING: "
    ;;
    e) level="ERROR:   "
    ;;
    *) level="UNKNOW:  "
    ;;
  esac
  if [[ -n "$LOG_FILE" ]] && [[ -w $LOG_FILE ]]; then
    echo "$(date +%Y/%m/%d\ %H:%M:%S) :$level$msg" >> "$LOG_FILE"
  else
    echo "ERROR:   no log file specified or it is not writable: $LOG_FILE"
    exit 1
  fi
}



###################################################
#execute shell script file
function execute_script() {
  SCRIPT_FILE=$1
  NEED_CONFIRM=$2

  FILENAME=$(echo "${SCRIPT_FILE}"| awk '{print $1}' )

  if [ -f ./cmd/"${FILENAME}" ]
  then

    #check file mod
    if [ ! -x ./cmd/"${FILENAME}" ]
    then
      chmod +x ./cmd/"${FILENAME}"
    fi

    echo
    if [ "${NEED_CONFIRM}" == "true" ]
    then
      #need confirm before execute script
      echo -e -n "${LEFT_PAD}${BOLD}${PURPLE}Are you sure to run script [${SCRIPT_FILE}]?${RESET} ('y' to continue, 'Enter' to cancel):"
      read CHOICE
    fi

    if [ "${NEED_CONFIRM}" == "true" -a "$CHOICE" != "y" ]
    then
      #need confirm, but doesn't input "y"
      echo "${LEFT_PAD}======================================================================="
      echo "${LEFT_PAD}${CYAN}Cancel run shell script [${SCRIPT_FILE}] ${RESET}"
      echo -e "${LEFT_PAD}=======================================================================\n"
      #mainMe;
      sleep 1
    else
      START_TIME=$(date +"%F %T")
      START_TS=$(date +"%s")

      #execute script file
      echo "${LEFT_PAD}${YELLOW}======================================================================="
      echo "${LEFT_PAD}Start run shell script file: [ ${BOLD}${WHITE}${SCRIPT_FILE}${YELLOW} ${RESET}${YELLOW}]"
      echo "${LEFT_PAD}=======================================================================${RESET}"

      log_message i "Start run shell script file: [${SCRIPT_FILE}]"
      ./cmd/${SCRIPT_FILE}

      echo -e "\n${LEFT_PAD}${YELLOW}======================================================================="
      echo "${LEFT_PAD}Run shell script  [ ${BOLD}${WHITE}${SCRIPT_FILE}${YELLOW} ${RESET}${YELLOW}] finish"
      echo "${LEFT_PAD}=======================================================================${RESET}"

      END_TIME=$(date +"%F %T")
      END_TS=$(date +"%s")

      echo -e "\n${LEFT_PAD}${YELLOW}[Start Time]: ${WHITE}${START_TIME}"
      echo "${LEFT_PAD}${YELLOW}[End Time]  : ${WHITE}${END_TIME}"
      echo -e "${LEFT_PAD}${YELLOW}[Duration]  : ${WHITE}$(((END_TS-START_TS))) (seconds)${RESET}\n"

      pause
    fi
  else
    echo -e "${LEFT_PAD}${BOLD}${RED}Can not found file [$(pwd)/cmd/${SCRIPT_FILE}], cancel!${RESET}"
    pause
  fi
}


###################################################
#show menu, read user input
function createMenu() {
  MAIN=$1
  TITLE=$2
  #Menu title
  show_message "${TITLE}" yellow bold
  echo
  echo -e "${LEFT_PAD}${Bt} No.  $(printf Name%-31s)  $(printf Description%-36s)${Et}"
  unset KEY_ARY
  KEY_ARY=( "e=e" )
  ##Create menuitem ##
  for (( i = 1 ; i <= ${#MI_NAME[@]} ; i++ ))
  do
    ITEM=${MI_ITEM[$i-1]}
    DESC=${MI_DESC[$i-1]}
    T=${MI_TYPE[$i-1]}
    SPLIT=${MI_SPLIT[$i-1]}
    CONFIRM=${MI_CONFIRM[$i-1]}
    KEY_ARY[$i]=$((i-1))
    HAS_SUBMENU="false"
    
    if [ "${MAIN}" == "main" ]
    then
      #check submenu
      OLD_IFS="$IFS" #save current IFS
      IFS=$'\x0A' #enter key
      _NO=$((i-1))
      MI_SUBMENU=( $(./util/${JQ} -r '.['${_NO}'].submenu[].MI_ITEM' etc/memu.conf 2>/dev/null) )
      IFS="$OLD_IFS"
      if [ "${#MI_SUBMENU[@]}" -gt 0 ]
      then
        ITEM="${ITEM} ${WHITE}"
        HAS_SUBMENU="true"
      fi
    else
      #remove top level menu
      _TMP=($3)
      unset _TMP[0]
      _TMP="${_TMP[@]}"
      _NO="$_TMP $((i-1))"
      #echo "getJqOption_current> \"${_NO}\" "
      _JQ_OPTION=$(getJqOption_current "${_NO}" )
      #echo "_JQ_OPTION:|${_JQ_OPTION}|"
      #check submenu
      OLD_IFS="$IFS" #save current IFS
      IFS=$'\x0A'
      #echo "./util/${JQ} -r ${_JQ_OPTION}"".submenu"" etc/memu.conf"
      MI_SUBMENU=$(./util/${JQ} -r ${_JQ_OPTION}".submenu" etc/memu.conf 2>/dev/null)
      #echo "MI_SUBMENU:${MI_SUBMENU}"
      #pause
      IFS="$OLD_IFS"
      if [ "${MI_SUBMENU}" != "null" ]
      then
        ITEM="${ITEM} ${WHITE}"
        HAS_SUBMENU="true"
      fi
    fi
    
    #add split line
    if [ $i -eq 1 ]
    then
      # splitter before first menuitem
      SPLIT="blank"
    fi
    if [ $i -eq ${#MI_NAME[@]} ]
    then
      # spliter before exit
      SPLIT="double"
    fi
    
    #echo "$i ${#MI_NAME[@]} ${SPLIT}"
    case "${SPLIT}" in
      "blank")echo
      ;;
      "single")echo -e "${LEFT_PAD}${THIN_LINE}"
      ;;
      "double")echo -e "${LEFT_PAD}${THICK_LINE}"
      ;;
      *)
    esac
    
    #show menuitem
    if [ "$T" == "exit" ]
    then
      echo -e "${LEFT_PAD}  e   ${CYAN}$(printf %-35s "<${ITEM}>")${RESET}"
    else
      if [ "${HAS_SUBMENU}" == "true"  ]
      then
        echo "${LEFT_PAD}  ${i}   ${BLUE}$(printf %-38s "${ITEM}")→  ${BOLD}${BLACK}${DESC}${RESET}"
      else
        echo "${LEFT_PAD}  ${i}   ${WHITE}$(printf %-35s "${ITEM}")  ${BOLD}${BLACK}${DESC}${RESET}"
      fi

    fi
  done
  echo -e "${LEFT_PAD}${THICK_LINE}\n"

  #Read and execute the user's selection
  echo -e "${LEFT_PAD}${BOLD}${YELLOW}Choice(Input No.):${RESET} \c"
  read -n2 CHOICE_ID
  CHOICE_RAW="$CHOICE_ID"
  
  #check input valid
  for key in "${KEY_ARY[@]}"
  do
    case ${CHOICE_ID} in
      1) break;;
      2) break;;
      3) break;;
      4) break;;
      5) break;;
      6) break;;
      7) break;;
      8) break;;
      9) break;;
      e)
        #valid
      break;;
      *)
        CHOICE_ID=""
      break;;
    esac
  done;
  #echo "${LEFT_PAD}You select: $CHOICE_ID"
  
  case "$CHOICE_ID" in
    e) #Escape[e]
      if [ "${MAIN}" == "main" ]
      then
        exit 1
      else
        CHOICE_NAME="e"
      fi
    ;;
    [[:digit:]]) #number
      CHOICE_NAME="${MI_NAME[${CHOICE_ID}-1]}"
      CHOICE_ITEM="${MI_ITEM[${CHOICE_ID}-1]}"
    ;;
    *)
      #Wrong
      echo "${LEFT_PAD}${BOLD}${WHITE}please input a <number> or 'e'${RESET}"
    ;;
  esac
}

###################################################
#generate jq option for get submenu
function getJqOption_submenu() {
  _NO=($1)
  #echo "_NO:'${_NO[@]}'"
  #echo "LEN:'${#_NO[@]}'"
  for (( i = 1 ; i < ${#_NO[@]} ; i++ ))
  do
    IDX=${_NO[$i]}
    #echo -n "=>$((IDX)) "
    if [ $i -eq 1 ]
    then
      _OPTION=".["$((IDX-1))"]"
    else
      _OPTION+=".submenu["$((IDX-1))"]"
    fi
  done
  echo "${_OPTION}"
}

###################################################
#generate jq option for get current menuitem
function getJqOption_current() {
  _NO=($1)
  #echo "_NO:'${_NO[@]}'"
  #echo "LEN:'${#_NO[@]}'"
  for (( i = 0 ; i < ${#_NO[@]} ; i++ ))
  do
    IDX=${_NO[$i]}
    #echo -n "=>$((IDX)) "
    if [ $i -eq 0 ]
    then
      _OPTION=".["$((IDX-1))"]"
    else
      _OPTION+=".submenu["$((IDX))"]"
    fi
  done
  echo "${_OPTION}"
}

################################################################
#generate & show menu, handle action
function showMenu() {
  NO=($1)
  TITLE="$2"
  
  lineMove
  
  #init menu array
  unset MI_TYPE
  unset MI_NAME
  unset MI_ITEM
  unset MI_DESC
  unset MI_SPLIT
  unset MI_CONFIRM
  unset CHOICE_NAME
  unset CHOICE_RAW
  unset CHOICE_ID
  unset CHOICE_ITEM
  
  CUR_LEVEL=${#NO[@]}
  #echo "CUR_LEVEL:$CUR_LEVEL"
  #echo "NO:$NO"
  #for (( i = 1 ; i <= ${#NO[@]} ; i++ ))
  #do
  #  echo "L:${NO[$i-1]}"
  #done
  
  if [ "${CUR_LEVEL}" -eq 1 ]
  then
    MENU_LEVEL="main"
    TITLE="[MainMenu] Hyper Develop Tool"
    
    #set IFS for split string to array
    OLD_IFS="$IFS" #save current IFS
    IFS=$'\x0A' #enter key
    
    #get main menuitem data
    MI_TYPE=( $(./util/${JQ} -r '.[].MI_TYPE' etc/memu.conf) )
    MI_NAME=( $(./util/${JQ} -r '.[].MI_NAME' etc/memu.conf) )
    MI_ITEM=( $(./util/${JQ} -r '.[].MI_ITEM' etc/memu.conf) )
    MI_DESC=( $(./util/${JQ} -r '.[].MI_DESC' etc/memu.conf) )
    MI_SPLIT=( $(./util/${JQ} -r '.[].MI_SPLIT' etc/memu.conf) )
    MI_CONFIRM=( $(./util/${JQ} -r '.[].MI_CONFIRM' etc/memu.conf) )
    MI_SUBMENU=( $(./util/${JQ} -r '.[].submenu' etc/memu.conf) )
    
    IFS="$OLD_IFS" #restore IFS
    
    #append exit item
    id=${#MI_NAME[@]}
    MI_TYPE[$id]="exit"
    MI_NAME[$id]="exit_shell"
    MI_ITEM[$id]="Exit"
    MI_DESC[$id]=" "
    MI_SPLIT[$id]="double"
    MI_CONFIRM[$id]=" "
    
    JQ_OPTION=".["$((CHOICE_ID))"]"
  else
    MENU_LEVEL="sub"
    
    #generate jq option
    _NO="${NO[@]}"
    JQ_OPTION=$(getJqOption_submenu "${_NO}" )
    
    #set IFS for split string to array
    OLD_IFS="$IFS" #save current IFS
    IFS=$'\x0A' #enter key
    
    #get sub menuitem data
    MI_TYPE=( $(./util/${JQ} -r "${JQ_OPTION}.submenu[].MI_TYPE" etc/memu.conf 2>/dev/null) )
    MI_NAME=( $(./util/${JQ} -r "${JQ_OPTION}.submenu[].MI_NAME" etc/memu.conf 2>/dev/null) )
    MI_ITEM=( $(./util/${JQ} -r "${JQ_OPTION}.submenu[].MI_ITEM" etc/memu.conf 2>/dev/null) )
    MI_DESC=( $(./util/${JQ} -r "${JQ_OPTION}.submenu[].MI_DESC" etc/memu.conf 2>/dev/null) )
    MI_SPLIT=( $(./util/${JQ} -r "${JQ_OPTION}.submenu[].MI_SPLIT" etc/memu.conf 2>/dev/null) )
    MI_CONFIRM=( $(./util/${JQ} -r "${JQ_OPTION}.submenu[].MI_CONFIRM" etc/memu.conf 2>/dev/null) )
    
    IFS="$OLD_IFS" #restore IFS
    
    #append return to mainmenu item
    id=${#MI_NAME[@]}
    MI_TYPE[$id]="exit"
    MI_NAME[$id]="return_mainmenu"
    MI_ITEM[$id]="Return to mainmenu"
    MI_DESC[$id]=" "
    MI_SPLIT[$id]="double"
    MI_CONFIRM[$id]=" "
  fi
  
  
  #############################
  #create menu
  #############################
  createMenu "${MENU_LEVEL}" "$TITLE" "$1"
  

  #############################
  #menu action
  #############################
  if [ "${CHOICE_NAME}" == "e" ]
  then
    echo "${CHOICE_NAME}"
    if [ "${MENU_LEVEL}" == "main" ]
    then
      ######exit######
      exit 1
    else
      ######return to mainmenu######

      #get PARENT_NO
      unset NO[$CUR_LEVEL-1]  #remove last one
      PARENT_NO="${NO[@]}"
      
      #get LAST_ID
      LEN="${#NO[@]}"
      LAST_ID=${NO[$LEN-1]}
      
      #get LAST_ITEM
      JQ_OPTION=$(getJqOption_submenu "${PARENT_NO}" )
      LAST_ITEM=$(./util/${JQ} -r "${JQ_OPTION}.MI_ITEM" etc/memu.conf 2>/dev/null)
      
      #echo "PARENT_NO:${PARENT_NO}"
      #echo "LAST_ID:${LAST_ID}"
      #echo "LAST_ITEM:${LAST_ITEM}"
      #pause
      
      showMenu "${PARENT_NO}" "[SubMenu] ${LAST_ID}.${LAST_ITEM}"
    fi
  elif echo "${MI_NAME[@]}" | grep -w "${CHOICE_NAME}" &>/dev/null
  then
    ###### input a valid command######
    #echo "${LEFT_PAD}[${MENU_LEVEL}]Found ${CHOICE_NAME}"
    #pause
    
    #generate jq option
    NEW_NO="$1 $CHOICE_ID" #append new menuitem
    JQ_OPTION=$(getJqOption_submenu "${NEW_NO}" )
    
    #check submenu
    OLD_IFS="$IFS" #save current IFS
    IFS=$'\x0A'
    #echo "./util/${JQ} -r "${JQ_OPTION}".submenu"" etc/memu.conf"
    MI_SUBMENU=$(./util/${JQ} -r "${JQ_OPTION}.submenu" etc/memu.conf 2>/dev/null)
    MI_CONFIRM=$(./util/${JQ} -r "${JQ_OPTION}.MI_CONFIRM" etc/memu.conf 2>/dev/null)
    #echo "MI_SUBMENU:${MI_SUBMENU}"
    #pause
    IFS="$OLD_IFS"
    if [ "${MI_SUBMENU}" != "null" ]
    then
      #echo "${LEFT_PAD}has submenu"
      _NO="$1 $CHOICE_ID"
      showMenu "${_NO}" "[SubMenu] ${CHOICE_ID}.${CHOICE_ITEM}"
    else
      #echo "${LEFT_PAD}has no submenu"

      execute_script "${CHOICE_NAME}" "${MI_CONFIRM}"
      _NO=("$1")
      showMenu "${_NO[@]}" "$2"
    fi
    
  else
    echo -e "${LEFT_PAD}${BOLD}${RED}Error： '${CHOICE_RAW}' is not a valid option; ${RESET}"
    sleep 1
    _NO=("$1")
    showMenu "${_NO[@]}" "$2"
  fi
  exit 1
}


#########################################################################
# Main
#########################################################################
showMenu  "0"
exit 1






#########################################################################
#for debug
#########################################################################
OLD_IFS="$IFS" #save current IFS
IFS=$'\x0A'

MI_TYPE=( $(./util/${JQ} -r '.[].MI_TYPE' etc/memu.conf) )
MI_NAME=( $(./util/${JQ} -r '.[].MI_NAME' etc/memu.conf) )
MI_ITEM=( $(./util/${JQ} -r '.[].MI_ITEM' etc/memu.conf) )
MI_DESC=( $(./util/${JQ} -r '.[].MI_DESC' etc/memu.conf) )
MI_SPLIT=( $(./util/${JQ} -r '.[].MI_SPLIT' etc/memu.conf) )
MI_CONFIRM=( $(./util/${JQ} -r '.[].MI_CONFIRM' etc/memu.conf) )

IFS="$OLD_IFS"

#./util/${JQ} -r '.[].MI_ITEM' etc/memu.conf
#echo --------------------------

for (( i = 1 ; i <= ${#MI_NAME[@]} ; i++ ))
do
  #echo "$i, ${MI_TYPE[$i]}, ${MI_NAME[$i]}, ${MI_ITEM[$i]}, ${MI_DESC[$i]}, ${MI_SPLIT[$i]}"
  echo "$i, ${MI_ITEM[$i-1]}"
  
  #get submenu
  OLD_IFS="$IFS" #save current IFS
  IFS=$'\x0A'
  NO=$((i-1))
  
  #echo
  #echo ------------------------------
  #./util/${JQ} -r '.['$NO'].submenu[].MI_ITEM' etc/memu.conf 2>/dev/null
  
  MI_SUBMENU=( $(./util/${JQ} -r '.['$NO'].submenu[].MI_ITEM' etc/memu.conf 2>/dev/null) )
  IFS="$OLD_IFS"
  
  for (( j = 1 ; j <= ${#MI_SUBMENU[@]} ; j++ ))
  do
    echo "    $j, ${MI_SUBMENU[$j-1]}"
  done
done
#########################################################################
