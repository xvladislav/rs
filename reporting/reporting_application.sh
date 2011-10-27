#!/bin/bash
# Copyright (c) 2011 SmileyMedia

# $REPORTING_APPLICATION_GIT_BRANCH -- remote git branch where Reporting Application application is located
# $REPORTING_APPLICATION -- The application name (will be created directory /opt/REPORTING_APPLICATION)
# $SSH_PRIVATE_KEY -- private ssh key for 'git' user

# Required packages: git-core unzip

#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip Reporting Application install on reboot."
  logger -t RightScale "Reporting Application Install,  skipped on a reboot."
  exit 0 
fi


DEPLOY_DIR=/opt/$REPORTING_APPLICATION
GIT_DOMAIN=`echo $REPORTING_APPLICATION_GIT_BRANCH | sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/"`


# Checkout code
echo "Prepare to deploy..."
mkdir -p $DEPLOY_DIR

mkdir -p ~/.ssh
echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa

cat <<EOF> ~/.ssh/config
Host $GIT_DOMAIN
StrictHostKeyChecking no
EOF

git clone $REPORTING_APPLICATION_GIT_BRANCH $DEPLOY_DIR

cd $DEPLOY_DIR
git submodule init
git submodule update


# Set file permissions
mkdir $DEPLOY_DIR/templates/templates_c
chgrp www-data $DEPLOY_DIR/templates/templates_c
chmod g+w $DEPLOY_DIR/templates/templates_c