#!/bin/bash -ex
# Copyright (c) 2011 SmileyMedia
# Script is based on "WEB Apache vhost non-rails configure - 11H1 [rev 2]"

# $REPORTING_WEBSITE_DNS -- DNS name of the web site (i.e., www.mysite.com)
# $REPORTING_APPLICATION -- The name of the user Application
# $ADMIN_EMAIL -- The email address used for Apache ServerAdmin in the Vhost.

#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip code install on reboot."
  logger -t RightScale "Skip code install on reboot."
  exit 0 # Leave with a smile ...
fi

if [ $RS_DISTRO = ubuntu ]; then 
  apache=apache2
elif [ $RS_DISTRO = centos ]; then
  apache=httpd
fi

## General Variables
DOC_ROOT=/opt/$REPORTING_APPLICATION/htdocs
LOG_DIR=/var/log/$apache


mkdir -p $LOG_DIR


cat <<EOF> /etc/$apache/sites-available/$REPORTING_APPLICATION
<VirtualHost *:80>
    ServerName $REPORTING_WEBSITE_DNS
    UseCanonicalName On

    ServerAdmin $ADMIN_EMAIL
    DocumentRoot "$DOC_ROOT"

    <Directory $DOC_ROOT>
      AllowOverride All
      Order Allow,Deny
      Allow from all
    </Directory>
</VirtualHost>
EOF

sudo a2ensite $REPORTING_APPLICATION
sudo service apache2 reload