#! /bin/bash

SMTPSERVER=localhost
FROM="<spoofer@spoof.com>"
TO="<thys.meintjes@nd.edu.au>"
SUBJECT="Mail test at $(date)"

function direct() {
(
echo "HELO";
sleep 2;
echo "MAIL FROM: ${FROM}";
sleep 2;
echo "RCPT TO: ${TO}";
sleep 2;
echo "DATA";
sleep 2;
echo -e "From: ${FROM}";
echo -e "Subject: ${SUBJECT}";
echo -e "<EMAIL BODY>."
echo -e "\n\n.";
sleep 3;
echo "QUIT";
) | telnet ${SMTPSERVER}  25
}


function here() {
telnet ${SMTPSERVER} 25 << EOMAIL
EHLO
MAIL FROM: ${FROM} 
RCPT TO: ${TO}
DATA
foo my bar at $(date)

\r\n.\r\n

EOMAIL
}

here
direct


