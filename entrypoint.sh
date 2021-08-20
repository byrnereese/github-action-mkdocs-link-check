#!/usr/bin/env bash

set -eu

NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'

#python3 -m pip install mkdocs-linkcheck

CMD='python -m mkdocs_linkcheck'

declare -a FIND_CALL
declare -a COMMAND_DIRS COMMAND_FILES
declare -a COMMAND_FILES

if [ -z "$1" ]; then
    EXCLUDES="__none__"
else
    EXCLUDES="$1"
fi
if [ -z "$2" ]; then
    FILE_EXTENSION=".md"
else
    FILE_EXTENSION="$2"
fi
FOLDER_PATH="$3"
LOCAL_ONLY="$4"
HTTP_METHOD="$5"
RECURSE="$6"
SYNC_MODE="$7"
USE_VERBOSE_MODE="$8"

echo -e "${BLUE}EXCLUDES: $1${NC}"
echo -e "${BLUE}FILE_EXTENSION: $2${NC}"
echo -e "${BLUE}FOLDER_PATH: $3${NC}"
echo -e "${BLUE}LOCAL_ONLY: $4${NC}"
echo -e "${BLUE}HTTP_METHOD: $5${NC}"
echo -e "${BLUE}RECURSE: $6${NC}"
echo -e "${BLUE}SYNC_MODE: $7${NC}"
echo -e "${BLUE}VERBOSE_MODE: $8${NC}"

handle_dirs () {

   IFS=', ' read -r -a DIRLIST <<< "$FOLDER_PATH"

   for index in "${!DIRLIST[@]}"
   do
      if [ ! -d "${DIRLIST[index]}" ]; then
	  # changing the behavior around this because I am not sure I understand how actions work
          echo -e "${RED}WARNING [✖] Can't find the directory: ${YELLOW}${DIRLIST[index]}${NC}"
          #echo -e "${RED}ERROR [✖] Can't find the directory: ${YELLOW}${DIRLIST[index]}${NC}"
          #exit 2
      fi
      COMMAND_DIRS+=("${DIRLIST[index]}")
   done
   FOLDERS="${COMMAND_DIRS[*]}"

}

check_errors () {

   if [ -e error.txt ] ; then
      if grep -q "ERROR:" error.txt; then
         echo -e "${YELLOW}=========================> MARKDOWN LINK CHECK <=========================${NC}"
         cat error.txt
         printf "\n"
         echo -e "${YELLOW}=========================================================================${NC}"
         exit 113
      else
         echo -e "${YELLOW}=========================> MARKDOWN LINK CHECK <=========================${NC}"
         printf "\n"
         echo -e "${GREEN}[✔] All links are good!${NC}"
         printf "\n"
         echo -e "${YELLOW}=========================================================================${NC}"
      fi
   else
      echo -e "${GREEN}All good!${NC}"
   fi

}

add_options () {
    
   if [ "$EXCLUDES" != "__none__" ]; then
      CMD+=("--exclude $EXCLUDES")
   fi
   
   if [ "$RECURSE" = "yes" ]; then
      CMD+=('--recurse')
   fi
   
   if [ "$LOCAL_ONLY" = "yes" ]; then
      CMD+=('--local')
   fi

   if [ "$SYNC_MODE" = "yes" ]; then
      CMD+=('--sync')
   fi

   if [ "$HTTP_METHOD" ]; then
      #CMD+=("--method $HTTP_METHOD")
      CMD+=("--method")
      CMD+=("$HTTP_METHOD")
   fi

   if [ "$FILE_EXTENSION" ]; then
      #CMD+=("--ext $FILE_EXTENSION")
      CMD+=("--ext")
      CMD+=("$FILE_EXTENSION")
   fi

   if [ "$USE_VERBOSE_MODE" = "yes" ]; then
      CMD+=('--verbose')
   fi

   if [ -d "$FOLDER_PATH" ]; then
      CMD+=("$FOLDER_PATH")
   fi

}

if [ -z "$3" ]; then
   FOLDERS="."
else
   handle_dirs
fi

add_options

set -x
"${CMD[@]}" &>> error.txt
set +x

check_errors
