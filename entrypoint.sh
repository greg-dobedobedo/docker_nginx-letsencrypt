#!/bin/bash

service cron start
exec nginx -g 'daemon off;'
