#!/bin/bash

envsubst '$APP_DOMAIN' < /client/nginx.conf > /etc/nginx/nginx.conf 
nginx -g 'daemon off;' &
npm start -- --config config.json
