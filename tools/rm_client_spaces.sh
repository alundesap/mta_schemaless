#!/bin/bash

orgname='deloitte'

xs target -o $orgname

clientfile='clients.txt'
password='Plak8484'

IFS=','

echo "Start"
echo ""
while read clientline; do
  echo $clientline
  echo ""
  read -r -a clientarray <<< "$clientline"
  clientfull=${clientarray[0]}
  spacename=${clientarray[1]}
  sqluser=${clientarray[2]}
  echo "Full: $clientfull"
  echo "Space: $spacename"
  echo "User: $sqluser"
  echo ""

  xs a | grep STARTED | cut -d ' ' -f 1 | while read -r line ; do echo "Stopping $line"; xs stop $line ; done

  xs delete-space $spacename -f --quiet

  echo "Removing SQL User."
  hdbsql -i 90 -n localhost:39013 -u SYSTEM -p $password "DROP USER $sqluser CASCADE"

  hdbsql -i 90 -n localhost:39013 -u SYSTEM -p $password "DROP SCHEMA $sqluser_1999"

  echo ""
done < $clientfile

echo "Finish"

xs org $orgname
if [ $? -eq 0 ]; then 
  echo "Org $orgname exists."
  xs delete-org $orgname -f
else
  echo "$orgname org already deleted."
fi


