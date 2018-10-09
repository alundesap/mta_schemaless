#!/bin/bash

orgname='deloitte'

xs org $orgname
if [ $? -eq 0 ]; then
  echo "Org $orgname exists."
else
  echo "Creating $orgnam org."
  xs create-org $orgname
fi

xs set-org-role XSA_ADMIN $orgname OrgManager

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
  echo "Creating SQL User."
  hdbsql -i 90 -n localhost:39013 -u SYSTEM -p $password "CREATE USER $sqluser PASSWORD $password NO FORCE_FIRST_PASSWORD_CHANGE SET PARAMETER XS_RC_XS_CONTROLLER_USER = 'XS_CONTROLLER_USER', XS_RC_DEVX_DEVELOPER = 'DEVX_DEVELOPER', XS_RC_XS_AUTHORIZATION_ADMIN = 'XS_AUTHORIZATION_ADMIN'"

  xs create-space $spacename -o $orgname
  xs set-space-role XSA_ADMIN,XSA_DEV,$sqluser $orgname $spacename SpaceManager
  xs set-space-role XSA_ADMIN,XSA_DEV,$sqluser $orgname $spacename SpaceDeveloper

  xs space-users $orgname $spacename

  xs target -o $orgname -s $spacename

  xs create-service hana hdi-shared hdi_db
#  xs create-service hana hdi-shared hdi_tax_year_2000
	
#  xs push $spacename.db -k 1024M -m 256M -p ../db --no-start --no-route
#  xs bind-service $spacename.db hdi_db
#  xs restart $spacename.db --wait-indefinitely ; sleep 10 ; xs stop $spacename.db

  hdbsql -i 90 -n localhost:39013 -u SYSTEM -p $password "CREATE SCHEMA $sqluser_1999 OWNED BY $sqluser"

  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'CREATE COLUMN TABLE "'$sqluser'_1999"."basis.contribution"( "contributionId" INTEGER CS_INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1), "partner" NVARCHAR(32) NOT NULL, "amount" DECIMAL(9, 2) CS_FIXED NOT NULL, "created" LONGDATE CS_LONGDATE NOT NULL) UNLOAD PRIORITY 5 AUTO MERGE'

  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'CREATE COLUMN TABLE "'$sqluser'_1999"."basis.withdrawl"( "withdrawlId" INTEGER CS_INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1), "partner" NVARCHAR(32) NOT NULL, "amount" DECIMAL(9, 2) CS_FIXED NOT NULL, "created" LONGDATE CS_LONGDATE NOT NULL) UNLOAD PRIORITY 5 AUTO MERGE'

  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'CREATE COLUMN TABLE "'$sqluser'_1999"."basis.income"( "incomeId" INTEGER CS_INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1), "partner" NVARCHAR(32) NOT NULL, "amount" DECIMAL(9, 2) CS_FIXED NOT NULL, "created" LONGDATE CS_LONGDATE NOT NULL) UNLOAD PRIORITY 5 AUTO MERGE'

  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'CREATE COLUMN TABLE "'$sqluser'_1999"."basis.loss"( "lossId" INTEGER CS_INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1), "partner" NVARCHAR(32) NOT NULL, "amount" DECIMAL(9, 2) CS_FIXED NOT NULL, "created" LONGDATE CS_LONGDATE NOT NULL) UNLOAD PRIORITY 5 AUTO MERGE'


  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'INSERT INTO "'$sqluser'_1999"."basis.contribution" VALUES('"'"$spacename"_partner'"',123.45,NOW())'

  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'INSERT INTO "'$sqluser'_1999"."basis.withdrawl" VALUES('"'"$spacename"_partner'"',123.45,NOW())'

  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'INSERT INTO "'$sqluser'_1999"."basis.income" VALUES('"'"$spacename"_partner'"',123.45,NOW())'

  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'INSERT INTO "'$sqluser'_1999"."basis.loss" VALUES('"'"$spacename"_partner'"',123.45,NOW())'

  echo ""
done < $clientfile

echo ""
echo "Finish"

declare -a array=("one" "two" "three")

# get length of an array
arraylength=${#array[@]}

# use for loop to read all values and indexes
for (( i=1; i<${arraylength}+1; i++ ));
do
  echo $i " / " ${arraylength} " : " ${array[$i-1]}
done

#cf t -o teched_dat368 -s dev00
#
#org=$(cf org teched_dat368 --guid); echo "teched_dat368: " $org
#hdb=$(cf service dat368-db --guid); echo "dat368-db: " $hdb
#spc=$(cf space dev00 --guid); echo "dev00: " $spc
#
## Run with the time command like so: time ./mkspaces_DAT368.sh
## there are 30 student laptops This script takes about 45mins to run for 30
#for i in {01..02}; do
#  echo ""
#  echo "Run" $i
#  cf create-space dev$i -o teched_dat368
#  spc=$(cf space dev$i --guid); echo "dev$i: " $spc
#  cf set-space-role primaryuser01@gmail.com teched_dat368 dev$i SpaceDeveloper
#  cf t -o teched_dat368 -s dev00
#  cf update-service dat368-db -c '{"operation":"adddatabasemapping","orgid":"'$org'","spaceid":"'$spc'","isdefault":"true"}'
#  cf t -s dev$i
#  cf create-service hana hdi-shared dat368-hdi -c '{"database_id":"'$hdb'"}'
#  cf services | grep dat368-hdi | grep "create succeeded"
#  while [ $? -ne 0 ]; do
#    cf services | grep dat368-hdi
#    echo "Still creating dat368-hdi in space dev$i."
#    sleep 30
#    cf services | grep dat368-hdi | grep "create succeeded"
#  done 
#echo "blah: $?"
#
#done
#
#cf t -o teched_dat368 -s dev00
