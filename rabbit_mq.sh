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
  echo "Skip RabbitMQ install on reboot."
  logger -t RightScale "RabbitMQ Install,  skipped on a reboot."
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


# 2. Install RabbitMQ server
cat <<EOF > /etc/apt/sources.list.d/rabbitmq.list
deb http://www.rabbitmq.com/debian/ testing main
EOF

wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc -O /tmp/rabbitmq-signing-key-public.asc
apt-key add /tmp/rabbitmq-signing-key-public.asc
rm /tmp/rabbitmq-signing-key-public.asc

apt-get -y update
apt-get -y install rabbitmq-server


#TODO: change /etc/rabbitmq/rabbitmq.config


service rabbitmq-server restart

logger -t RightScale "Installed RabbitMQ"