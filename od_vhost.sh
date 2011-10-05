#!/bin/bash -ex
# Copyright (c) 2011 SmileyMedia
# Script is based on "WEB Apache vhost non-rails configure - 11H1 [rev 2]"

# $WEBSITE_DNS -- DNS name of the web site (i.e., www.mysite.com)
# $APPLICATION -- The name of the user Application
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
DOC_ROOT=/opt/$APPLICATION/current
LOG_DIR=/var/log/$apache


mkdir -p $LOG_DIR


cat <<EOF> /etc/$apache/sites-available/$APPLICATION
<VirtualHost *:80>
    ServerName $WEBSITE_DNS
    UseCanonicalName On

    ServerAdmin $ADMIN_EMAIL
    DocumentRoot $DOC_ROOT/public/frontend/

    <Directory "$DOC_ROOT/public/frontend/">
      Options FollowSymLinks
      AllowOverride All
      Order allow,deny
      Allow from all
    </Directory>

     CustomLog $LOG_DIR/$APPLICATION.log combined
</VirtualHost>

<VirtualHost *:80>
    ServerName admin.$WEBSITE_DNS
    UseCanonicalName On

    ServerAdmin $ADMIN_EMAIL
    DocumentRoot $DOC_ROOT/public/backend/

    <Directory "$DOC_ROOT/public/backend/">
      Options FollowSymLinks
      AllowOverride All
      Order allow,deny
      Allow from all
    </Directory>

    CustomLog $LOG_DIR/$APPLICATION.log combined
</VirtualHost>

EOF

ln -s /etc/$apache/sites-available/$APPLICATION /etc/$apache/sites-enabled/
