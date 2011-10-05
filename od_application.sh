#!/bin/bash
# Copyright (c) 2011 SmileyMedia

# $APPLICATION -- The application name (will be created directory /opt/APPLICATION)
# $SSH_PRIVATE_KEY -- private ssh key for 'git' user
# $APPLICATION_GIT_BRANCH -- remote git branch where OD application is located
# $APPLICATION_YII_SVN_BRANCH -- remote svn branch where yii framework is located (for example: http://yii.googlecode.com/svn/trunk/framework)

#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip OD Application install on reboot."
  logger -t RightScale "OD Application Install,  skipped on a reboot."
  exit 0
fi

## TODO: change DEPLOY_DATE to version or revision?
DEPLOY_DATE=$(date "+%Y%m%d%H%M%S")

CONTENT_DIR=/opt/$APPLICATION/releases
CURRENT_DIR=/opt/$APPLICATION/current
DEPLOY_DIR=$CONTENT_DIR/$DEPLOY_DATE
APPLICATION_YII_DIRECTORY=/opt/$APPLICATION/yii
GIT_DOMAIN=`echo $APPLICATION_GIT_BRANCH | sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/"`



## General Preparation
echo "General Preparation..."
mkdir -p $CONTENT_DIR
rm -rf $DEPLOY_DIR


## Release/Deploy date of the application
echo "Prepare to deploy..."
mkdir -p $DEPLOY_DIR


mkdir -p ~/.ssh
echo $SSH_PRIVATE_KEY > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa

cat <<EOF> ~/.ssh/config
Host $GIT_DOMAIN
StrictHostKeyChecking no
EOF

git clone $APPLICATION_GIT_BRANCH $DEPLOY_DIR

cd $DEPLOY_DIR
git submodule init
git submodule update


# checkout from yii framework
mkdir -p $APPLICATION_YII_DIRECTORY
svn checkout $APPLICATION_YII_SVN_BRANCH $APPLICATION_YII_DIRECTORY


# change file permissions
cd $DEPLOY_DIR
chgrp www-data log
chmod g+w log

chgrp www-data public/frontend/assets
chmod g+w public/frontend/assets

chgrp www-data public/backend/assets
chmod g+w public/backend/assets

[ -h $CURRENT_DIR ] && unlink $CURRENT_DIR
ln -nfs $DEPLOY_DIR $CURRENT_DIR


logger -t RightScale "Deployed OD Application"
