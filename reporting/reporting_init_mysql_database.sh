#!/bin/bash
# Copyright (c) 2011 SmileyMedia

# RightScript for initializing Mysql Database for reporting application in staging and dev

# $DATABASE_OWNER_NAME -- the user name for database
# $REPORTING_APPLICATION -- The name of the user Application

# Run scripts before this: Mysql Install

#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip Reporting Mysql Database install on reboot."
  logger -t RightScale "Reporting Mysql Database Install,  skipped on a reboot."
  exit 0 
fi

id $DATABASE_OWNER_NAME

if [[ "$?" -ne "0" ]]; then
	adduser --system --no-create-home $DATABASE_OWNER_NAME
fi

SQL_SCHEMA_PATH=/opt/$REPORTING_APPLICATION/sql/schema.sql

mysql -uroot <<EOD
drop database odreports;
create database odreports;
grant all privileges on odreports.* to 'odreports'@'localhost' identified by 'odreports';
use odreports;
source $SQL_SCHEMA_PATH;
EOD