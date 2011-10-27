#!/bin/bash
# Copyright (c) 2011 SmileyMedia


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