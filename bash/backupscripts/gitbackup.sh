#!/bin/bash

USER=ftpuser
PASSWORD=sectret
SERVER=ftpserver
GITHOME=/home/git/
REPOSITORY=${GITHOME}/repos/
BACKUP_FOLDER=${GITHOME}/backup/
BACKUP_NAME=git-$(date +"%F").tgz

PATH=/bin:/usr/bin/
export PATH

ftpToBackup() {
   lftp -d -u ${USER},${PASSWORD} -e "set ftp:ssl-protect-data yes" ${SERVER} << EOF
mrm *.gz
mput -E ${BACKUP_FOLDER}/*.tgz
bye
EOF
}

cleanOldDump() {
   rm ${BACKUP_FOLDER}/*
}

tarRepos() {
   tar czvf ${BACKUP_FOLDER}/${BACKUP_NAME} ${REPOSITORY}
}

cleanOldDump
tarRepos
ftpToBackup

