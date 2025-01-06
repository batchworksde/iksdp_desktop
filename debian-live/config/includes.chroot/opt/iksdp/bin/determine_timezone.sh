#!/bin/bash

echo "automatic timezone configuration running..." >> /tmp/timezone.log

nc -z -v -w 5 ipapi.com 443

if [ "$?" -ne 0 ]; then
  echo "automatic timezone configuration failed..." >> /tmp/timezone.log
  exit 1
fi

export MY_TIMEZONE="$(curl --fail https://ipapi.co/timezone)"

timedatectl set-timezone $MY_TIMEZONE
echo $MY_TIMEZONE > /etc/timezone