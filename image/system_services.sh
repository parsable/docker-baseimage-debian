#!/bin/bash
set -e
source /build/buildconfig
set -x

## Install init process.
cp /build/bin/my_init /sbin/
mkdir -p /etc/my_init.d
mkdir -p /etc/container_environment
touch /etc/container_environment.sh
touch /etc/container_environment.json
chmod 700 /etc/container_environment

groupadd -g 8377 docker_env
chown :docker_env /etc/container_environment.sh /etc/container_environment.json
chmod 640 /etc/container_environment.sh /etc/container_environment.json
ln -s /etc/container_environment.sh /etc/profile.d/

## Install python3 for my_init
$minimal_apt_get_install python3

## Install runit.
$minimal_apt_get_install runit

## Install rsyslog and the with RELP protocol library, useful to send syslog events to a syslog server
$minimal_apt_get_install rsyslog librelp0
mkdir /etc/service/rsyslog
cp /build/runit/rsyslog /etc/service/rsyslog/run
# Disable kernel error logs since we're in a docker container
sed -i 's/^$ModLoad imklog/#$ModLoad imklog/' /etc/rsyslog.conf

## Install syslog to "docker logs" forwarder.
mkdir /etc/service/syslog-forwarder
cp /build/runit/syslog-forwarder /etc/service/syslog-forwarder/run

## Install logrotate.
$minimal_apt_get_install logrotate
cp /build/config/logrotate_rsyslog /etc/logrotate.d/rsyslog

## Install cron daemon.
$minimal_apt_get_install cron
mkdir /etc/service/cron
chmod 600 /etc/crontab
cp /build/runit/cron /etc/service/cron/run

## Remove useless cron entries.
# Checks for lost+found and scans for mtab.
rm -f /etc/cron.daily/standard
