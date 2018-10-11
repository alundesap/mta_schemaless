#!/bin/bash

orgname='deloitte'

xs org $orgname
if [ $? -eq 0 ]; then
  echo "Org $orgname exists."
else
  echo "Creating $orgnam org."
  xs create-org $orgname
fi

# xs set-org-role XSA_ADMIN $orgname OrgManager

# xs target -o $orgname

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

#  echo "Creating SQL User=$sqluser"
#  hdbsql -i 90 -n localhost:39013 -u SYSTEM -p $password "CREATE USER $sqluser PASSWORD $password NO FORCE_FIRST_PASSWORD_CHANGE SET PARAMETER XS_RC_XS_CONTROLLER_USER = 'XS_CONTROLLER_USER', XS_RC_DEVX_DEVELOPER = 'DEVX_DEVELOPER', XS_RC_XS_AUTHORIZATION_ADMIN = 'XS_AUTHORIZATION_ADMIN'"

#  echo "Creating space=$spacename"
#  xs create-space $spacename -o $orgname
#  xs set-space-role XSA_ADMIN,XSA_DEV,$sqluser $orgname $spacename SpaceManager
#  xs set-space-role XSA_ADMIN,XSA_DEV,$sqluser $orgname $spacename SpaceDeveloper

#  xs space-users $orgname $spacename

  xs target -o $orgname -s $spacename

#  xs create-service hana hdi-shared hdi_db
	
#  echo "Creating SCHEMA="$sqluser"_1999"
#  hdbsql -i 90 -n localhost:39013 -u SYSTEM -p $password "CREATE SCHEMA "$sqluser"_1999 OWNED BY $sqluser"

# Need to work out the permissions.
#https://blogs.sap.com/2017/01/07/synonyms-in-hana-xs-advanced-accessing-objects-in-an-external-schema/

#create role "APOLLO_1999::external_access";
#grant select on schema APOLLO_1999 to "APOLLO_1999::external_access";

#  echo "Creating TABLE="$sqluser"_1999 basis.contribution"
#  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'CREATE COLUMN TABLE "'$sqluser'_1999"."basis.contribution"( "contributionId" INTEGER CS_INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1), "partner" NVARCHAR(32) NOT NULL, "amount" DECIMAL(9, 2) CS_FIXED NOT NULL, "created" LONGDATE CS_LONGDATE NOT NULL) UNLOAD PRIORITY 5 AUTO MERGE'
#
#  echo "Creating TABLE="$sqluser"_1999 basis.withdraw"
#  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'CREATE COLUMN TABLE "'$sqluser'_1999"."basis.withdrawl"( "withdrawlId" INTEGER CS_INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1), "partner" NVARCHAR(32) NOT NULL, "amount" DECIMAL(9, 2) CS_FIXED NOT NULL, "created" LONGDATE CS_LONGDATE NOT NULL) UNLOAD PRIORITY 5 AUTO MERGE'
#
#  echo "Creating TABLE="$sqluser"_1999 basis.income"
#  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'CREATE COLUMN TABLE "'$sqluser'_1999"."basis.income"( "incomeId" INTEGER CS_INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1), "partner" NVARCHAR(32) NOT NULL, "amount" DECIMAL(9, 2) CS_FIXED NOT NULL, "created" LONGDATE CS_LONGDATE NOT NULL) UNLOAD PRIORITY 5 AUTO MERGE'
#
#  echo "Creating TABLE="$sqluser"_1999 basis.loss"
#  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'CREATE COLUMN TABLE "'$sqluser'_1999"."basis.loss"( "lossId" INTEGER CS_INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1), "partner" NVARCHAR(32) NOT NULL, "amount" DECIMAL(9, 2) CS_FIXED NOT NULL, "created" LONGDATE CS_LONGDATE NOT NULL) UNLOAD PRIORITY 5 AUTO MERGE'
#
#
#  echo "Inserting INTO : "$sqluser"_1999 basis.contribution"
#  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'INSERT INTO "'$sqluser'_1999"."basis.contribution" VALUES('"'"$spacename"_partner'"',123.45,NOW())'
#
#  echo "Inserting INTO : "$sqluser"_1999 basis.withdrawl"
#  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'INSERT INTO "'$sqluser'_1999"."basis.withdrawl" VALUES('"'"$spacename"_partner'"',123.45,NOW())'
#
#  echo "Inserting INTO : "$sqluser"_1999 basis.income"
#  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'INSERT INTO "'$sqluser'_1999"."basis.income" VALUES('"'"$spacename"_partner'"',123.45,NOW())'
#
#  echo "Inserting INTO : "$sqluser"_1999 basis.loss"
#  hdbsql -i 90 -n localhost:39013 -u $sqluser -p $password 'INSERT INTO "'$sqluser'_1999"."basis.loss" VALUES('"'"$spacename"_partner'"',123.45,NOW())'
#

#  echo "xs push hana.db"
#  xs push hana.db -k 1024M -m 256M -p ../db --no-start --no-route

#  echo "xs binding hana.db to hdi_db"
#  xs bind-service hana.db hdi_db

#  echo "xs restarting hana.db and stopping after 10 secs."
#  xs restart hana.db --wait-indefinitely ; sleep 10 ; xs stop hana.db

#  VCAP_SERVICES=$(xs env hana.db --export-json /dev/stdout 2>/dev/null | tail -n +5) ; echo $VCAP_SERVICES 

  HDI_SCHEMA=$(xs env hana.db --export-json /dev/stdout 2>/dev/null | tail -n +5 | jq -r '.VCAP_SERVICES.hana[0].credentials.schema') ; echo "SCHEMA="$HDI_SCHEMA
  HDI_USER=$(xs env hana.db --export-json /dev/stdout 2>/dev/null | tail -n +5 | jq -r '.VCAP_SERVICES.hana[0].credentials.user') ; echo "USER="$HDI_USER
  HDI_PASS=$(xs env hana.db --export-json /dev/stdout 2>/dev/null | tail -n +5 | jq -r '.VCAP_SERVICES.hana[0].credentials.password') ; echo "PASS="$HDI_PASS

  echo ""
  echo "Inserting INTO : "$HDI_SCHEMA" basis.contribution as "$HDI_USER" and generated password."
  hdbsql -i 90 -n localhost:39013 -u $HDI_USER -p $HDI_PASS 'INSERT INTO "'$HDI_SCHEMA'"."mta_schemaless.db.data::basis.contribution" VALUES('"'"$spacename"_partner_via_sql'"',987.65,NOW())'
  echo "Inserting INTO : "$HDI_SCHEMA" basis.income as "$HDI_USER" and generated password."
  hdbsql -i 90 -n localhost:39013 -u $HDI_USER -p $HDI_PASS 'INSERT INTO "'$HDI_SCHEMA'"."mta_schemaless.db.data::basis.income" VALUES('"'"$spacename"_partner_via_sql'"',987.65,NOW())'
  echo "Inserting INTO : "$HDI_SCHEMA" basis.loss as "$HDI_USER" and generated password."
  hdbsql -i 90 -n localhost:39013 -u $HDI_USER -p $HDI_PASS 'INSERT INTO "'$HDI_SCHEMA'"."mta_schemaless.db.data::basis.loss" VALUES('"'"$spacename"_partner_via_sql'"',987.65,NOW())'
  echo "Inserting INTO : "$HDI_SCHEMA" basis.withdrawl as "$HDI_USER" and generated password."
  hdbsql -i 90 -n localhost:39013 -u $HDI_USER -p $HDI_PASS 'INSERT INTO "'$HDI_SCHEMA'"."mta_schemaless.db.data::basis.withdrawl" VALUES('"'"$spacename"_partner_via_sql'"',987.65,NOW())'

#  echo "xs push hana.xsjs"
#  xs push hana.xsjs -k 1024M -m 256M -p ../xsjs --no-start

#  echo "xs binding hana.xsjs to hdi_db"
#  xs bind-service hana.xsjs hdi_db

# Following this blog https://blogs.sap.com/2017/01/07/synonyms-in-hana-xs-advanced-accessing-objects-in-an-external-schema/

#xs cups tax-year-1999 -p '{"host":"hxehost","port":"39013","user":"APOLLO","password":"Plak8484","driver":"com.sap.db.jdbc.Driver","tags":["hana"],"schema":"APOLLO_1999"}'

#  echo "xs binding hana.xsjs to tax-year-1999"
#  xs bind-service hana.xsjs tax-year-1999

#  echo "xs restarting hana.xsjs."
#  xs restart hana.xsjs --wait-indefinitely


  echo ""
done < $clientfile

echo ""
echo "Finish"

