#!/bin/bash
# Copyright (c) 2011 SmileyMedia

# $NGINX_HTTP_PUSH_MODULE_PORT -- port that will be listening by nginx_http_push_module (by default 8000)
# $NGINX_HTTP_PUSH_MODULE_DNS -- DNS name of the nginx_http_push_module (for example "q.od.dev")

# Required packages: python-software-properties

if [[ -z "$NGINX_HTTP_PUSH_MODULE_PORT" ]]; then
	NGINX_HTTP_PUSH_MODULE_PORT=8000
fi

nginx=stable # use nginx=development for latest development version
add-apt-repository ppa:nginx/$nginx
apt-get update
apt-get install -y nginx-extras


CONFIG_PATH=/etc/nginx/sites-available/comet

cat <<EOF> $CONFIG_PATH
server {
    listen       $NGINX_HTTP_PUSH_MODULE_PORT;
    server_name  $NGINX_HTTP_PUSH_MODULE_DNS;


    location /publish {
        push_publisher;
        set \$push_channel_id \$arg_key;
        set \$push_jsonp_callback \$arg_callback;

        push_store_messages on;
        push_min_message_buffer_length 0;
        push_max_message_buffer_length 20;
        push_message_timeout 2s;
        push_delete_oldest_received_message on;
        default_type  text/json;
    }

    location /activity {
        push_subscriber;
        set \$push_channel_id \$arg_key;

        push_subscriber_concurrency first;

        add_header Content-Type "text/javascript; charset=UTF-8";
        default_type  text/javascript;
    }

}
EOF

ln -s $CONFIG_PATH /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
service nginx restart