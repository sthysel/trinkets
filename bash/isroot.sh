#! /bin/bash
# thys

function isRoot() {
   if [[ ${EUID} -ne 0 ]]
   then
      echo "$0 needs to be run as root."
      exit 1
   else
      echo "$0 is rooty"
   fi
}

isRoot

