FROM phusion/baseimage:0.9.17

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

## Set TERM so that nano and vi won't be weird
ENV TERM xterm

## Fix UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; \
        echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale; \
        locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8

## Add PHP 5.6 repo
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php5-5.6

## Packages
RUN apt-get update && apt-get -y install curl unzip git rtorrent supervisor php5-fpm nginx php5-cli unrar mediainfo libav-tools php-apc nano irssi libarchive-zip-perl libhtml-parser-perl libxml-libxml-perl libdigest-sha-perl libjson-perl libjson-xs-perl libcrypt-ssleay-perl wget apache2-utils

## Configure php5-fpm
RUN php5enmod opcache

## Configure a user for rtorrent
RUN useradd rtorrent

## Create group for rTorrent unix socket
RUN groupadd rtorrent-scgi

## Create group for ruTorrent to access files it needs
RUN groupadd rtorrent-webaccess

## Add rtorrent and www-data to rTorrent socket/web access group
RUN usermod -a -G rtorrent-scgi www-data && usermod -a -G rtorrent-scgi rtorrent && usermod -a -G rtorrent-webaccess www-data && usermod -a -G rtorrent-webaccess rtorrent

## Link avconv
RUN ln -s /usr/bin/avconv /usr/bin/ffmpeg

## Setup runit
RUN mkdir /etc/service/rtorrent
ADD runit/rtorrent /etc/service/rtorrent/run
RUN mkdir /etc/service/php5-fpm
ADD runit/php5-fpm /etc/service/php5-fpm/run
RUN mkdir /etc/service/nginx
ADD runit/nginx /etc/service/nginx/run
RUN mkdir /etc/service/irssi
ADD runit/irssi /etc/service/irssi/run

## Setup NGINX
RUN rm /etc/nginx/sites-enabled/default
ADD nginx/default /etc/nginx/sites-enabled/default

## Add Docker Assets
ADD data/docker /docker

## Expose our port
EXPOSE 80

## Clean Up
USER root
WORKDIR /root
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
