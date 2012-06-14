#!/bin/bash
# thysm

DOMAIN="thys.com"
SITES="wunder bar blinkenlights"
PROTOCOLS="http:// https://"

function ok() {
   if [ $? -gt 0 ]
   then
      echo "Could not successfully scan $1 $2 "
      exit 1
   else
      echo "$1 $2 Scanned OK"
   fi
}

function sitetest() {
   for s in ${SITES}
   do
      for pr in ${PROTOCOLS}
      do
         SITE=${pr}${s}.${DOMAIN}
         curl -L ${SITE}
         ok site ${SITE}
      done
   done
}

sitetest
