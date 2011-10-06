#!/bin/bash
# Copyright (c) 2011 SmileyMedia

#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip MongoDB install on reboot."
  logger -t RightScale "MongoDB Install,  skipped on a reboot."
  exit 0 
fi

apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

# on a Debianoid with SysV style init scripts
# deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen

echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" >> /etc/apt/sources.list

apt-get update
apt-get install mongodb-10gen

# TODO: change /etc/mongodb.conf


logger -t RightScale "Installed MongoDB"
