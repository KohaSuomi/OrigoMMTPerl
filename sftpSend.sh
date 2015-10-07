#!/bin/bash
echo "Sending all prepared migration files to kohasuomi sftpserver"
sftp -b /dev/stdin ksftp <<EOF
cd private
#mkdir OrigoComplete
put OrigoComplete/* OrigoComplete/
cd /public
#mkdir konversiologit
put logs/* konversiologit/
EOF
