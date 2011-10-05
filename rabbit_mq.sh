#!/bin/bash
# Copyright (c) 2011 SmileyMedia

#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip RabbitMQ install on reboot."
  logger -t RightScale "RabbitMQ Install,  skipped on a reboot."
  exit 0 
fi

apt-get install -y rabbitmq-server

service rabbitmq-server start

#TODO: change /etc/rabbitmq/rabbitmq.config

logger -t RightScale "Installed RabbitMQ"
