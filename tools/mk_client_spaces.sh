#!/bin/bash

xs create-org deloitte

declare -a array=("one" "two" "three")

# get length of an array
arraylength=${#array[@]}

# use for loop to read all values and indexes
for (( i=1; i<${arraylength}+1; i++ ));
do
  echo $i " / " ${arraylength} " : " ${array[$i-1]}
done

cf t -o teched_dat368 -s dev00

org=$(cf org teched_dat368 --guid); echo "teched_dat368: " $org
hdb=$(cf service dat368-db --guid); echo "dat368-db: " $hdb
spc=$(cf space dev00 --guid); echo "dev00: " $spc

# Run with the time command like so: time ./mkspaces_DAT368.sh
# there are 30 student laptops This script takes about 45mins to run for 30
for i in {01..02}; do
  echo ""
  echo "Run" $i
  cf create-space dev$i -o teched_dat368
  spc=$(cf space dev$i --guid); echo "dev$i: " $spc
  cf set-space-role primaryuser01@gmail.com teched_dat368 dev$i SpaceDeveloper
  cf t -o teched_dat368 -s dev00
  cf update-service dat368-db -c '{"operation":"adddatabasemapping","orgid":"'$org'","spaceid":"'$spc'","isdefault":"true"}'
  cf t -s dev$i
  cf create-service hana hdi-shared dat368-hdi -c '{"database_id":"'$hdb'"}'
  cf services | grep dat368-hdi | grep "create succeeded"
  while [ $? -ne 0 ]; do
    cf services | grep dat368-hdi
    echo "Still creating dat368-hdi in space dev$i."
    sleep 30
    cf services | grep dat368-hdi | grep "create succeeded"
  done 
echo "blah: $?"

done

cf t -o teched_dat368 -s dev00
