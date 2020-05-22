#!/bin/bash

LOG=log
UP=login-pass

echo ${config} | base64 -D -o client.ovpn > /dev/null 2>&1

echo ${login} >> ${UP}
echo ${password} >> ${UP}

echo "" > ${LOG}


if [ -n "$login" ]; then
 echo "Connecting with login and password" 
 sudo openvpn --config client.ovpn --auth-user-pass ${UP} --daemon OVPN_DAEMON --verb 1 --log ${LOG}
else
 echo "Connecting without login and password"
 sudo openvpn --config client.ovpn --daemon OVPN_DAEMON --verb 1 --log ${LOG}
fi


if [ $? -ne 0 ]; then
 cat ${LOG}
 exit 1
fi


for i in {1..20}
do
 if [[ $(tail -1 ${LOG}) == *"Initialization Sequence Completed"* ]]; then
  cat ${LOG}
  echo "CONNECTED!"
  exit
 fi

 if [[ $i == 20 ]]; then
  cat ${LOG}
  echo "FAIL"
  exit 1
 fi

 sleep 1
done
