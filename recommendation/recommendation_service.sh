#!/bin/bash
# Copyright (c) 2011 SmileyMedia

# $APPLICATION_GIT_BRANCH -- remote git branch where Recommendation System application is located
# $SSH_PRIVATE_KEY -- private ssh key for 'git' user
# $POM_XML_PATCH -- patch for pom.xml file
# $TOMCAT_HOME -- tomcat home directory (/var/lib/tomcat6)
# $WEKA_DOWNLOAD_URL -- URL for downloading weka

# Required packages: git-core unzip tomcat6 maven2

#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip Recommendation Web Service install on reboot."
  logger -t RightScale "Recommendation Web Service Install,  skipped on a reboot."
  exit 0 
fi


# install weka
wget $WEKA_DOWNLOAD_URL
apt-get install -y unzip
unzip weka-*.zip -d /opt
ln -sf /opt/weka-* /opt/weka

# deploy recommendation service
DEPLOY_DIR=/opt/recomendation_service
GIT_DOMAIN=`echo $APPLICATION_GIT_BRANCH | sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/"`

mkdir -p ~/.ssh
echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa

cat <<EOF> ~/.ssh/config
Host $GIT_DOMAIN
StrictHostKeyChecking no
EOF

git clone $APPLICATION_GIT_BRANCH $DEPLOY_DIR

cd $DEPLOY_DIR

# changing pom.xml
if [ "$POM_XML_PATCH" ]; then
	echo "$POM_XML_PATCH" > /tmp/pom.xml.patch
	patch -f -p0 $DEPLOY_DIR/pom.xml /tmp/pom.xml.patch
fi


mvn compile
mvn install:install-file -DgroupId=weka -DartifactId=weka -Dversion=3.6 -Dpackaging=jar -Dfile=/opt/weka/weka.jar
mvn package
mvn install

cp ~/.m2/repository/smiley/od/ODWS/*/ODWS-*.war $TOMCAT_HOME/webapps/

service tomcat6 restart
