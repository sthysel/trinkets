#!/bin/bash

USER=ftpuser
PASSWORD="secret"
SERVER=ftpserver
BACKUPSOURCE=/var/atlassian/application-data/confluence/backups/

PATH=/bin:/usr/bin/
export PATH


findLatestBackup() {
  find ${BACKUPSOURCE} -type f -mtime -1
}

ftpToBackup() {
   lftp -d -u ${USER},${PASSWORD} -e "set ftp:ssl-protect-data yes" ${SERVER} << EOF
mput -E $1
bye
EOF
}

ftpToBackup $(findLatestBackup)

