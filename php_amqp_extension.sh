#!/bin/bash
# Copyright (c) 2011 SmileyMedia

# $RABBITMQ_C_DOWNLOAD_URL -- url for dowloading .gz archive of rabbitmq-c (for example http://hg.rabbitmq.com/rabbitmq-c/archive/default.tar.gz)
# $RABBITMQ_CODEGEN_DOWNLOAD_URL -- url for dowloading .gz archive of rabbitmq-codegen (for example http://hg.rabbitmq.com/rabbitmq-codegen/archive/default.tar.gz)


# Run right scripts before: Apache Install, PHP Install
# Required packages: unzip autoconf make libtool php-pear


#
# Test for a reboot,  if this is a reboot just skip this script.
#
if test "$RS_REBOOT" = "true" ; then
  echo "Skip PHP AMQP Extension install on reboot."
  logger -t RightScale "PHP AMQP Extension Install,  skipped on a reboot."
  exit 0 
fi


# 1. Install amqp extension for PHP
# TODO: install from ppa
cd /tmp
wget $RABBITMQ_C_DOWNLOAD_URL -O rabbitmq-c.gz
tar -zxvf rabbitmq-c.gz -C /tmp/

wget $RABBITMQ_CODEGEN_DOWNLOAD_URL -O codegen.gz
tar -zxvf codegen.gz -C /tmp/rabbitmq-c*/

cd /tmp/rabbitmq-c*/
mv *codegen* codegen

autoreconf -i && ./configure && make && make install
pecl install amqp-beta
sudo sh -c "echo 'extension = amqp.so' > /etc/php5/conf.d/amqp.ini"

logger -t RightScale "Installed PHP AMQP Extension"