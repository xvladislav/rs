#!/bin/bash
# Copyright (c) 2011 SmileyMedia

# $GIT_USERNAME  -- User name for git configuration
# $GIT_EMAIL  -- Email for git configuration

#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip RCS install on reboot."
  logger -t RightScale "RCS Install,  skipped on a reboot."
  exit 0 
fi

apt-get install -y svn git-core

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"


logger -t RightScale "Installed svn and git"
