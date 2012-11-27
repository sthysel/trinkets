#! /bin/bash

USER=ftpuser
PASSWORD=secret
SERVER=ftpserver
REPOSITORY=/home/subversion/repositories/bs
BACKUP_FOLDER=./backup/


svndump() {
   svnadmin dump ${REPOSITORY} | gzip > ${BACKUP_FOLDER}/bs.svn.gz
}


ftpToBackup() {
   lftp -d -u ${USER},${PASSWORD} -e "set ftp:ssl-protect-data yes" ${SERVER} << EOF
cd /${USER}
mrm *.svn.gz
mput -E ${BACKUP_FOLDER}/*.svn.gz
bye
EOF
}

cleanOldDump() {
   rm ${BACKUP_FOLDER}/*
}

cleanOldDump
svndump
ftpToBackup

