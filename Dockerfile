FROM phusion/baseimage:latest

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

## Set some environment variables
ENV TERM xterm

## Fix UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; \
        echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale; \
        locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8

## Add PHP 5.6 repo
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php5-5.6

## Packages
RUN apt-get update && apt-get -y install curl unzip git rtorrent supervisor php5-fpm nginx php5-cli unrar mediainfo libav-tools php-apc nano

## Configure php5-fpm
RUN php5enmod opcache

## Configure a user for git and allow users to login via ssh
RUN useradd rtorrent \
    && mkdir /home/rtorrent \
    && chown rtorrent: /home/rtorrent \
    && passwd -d rtorrent

## Create group for rTorrent socket
RUN groupadd rtorrent-scgi

## Add rtorrent and www-data to rTorrent socket group
RUN usermod -a -G rtorrent-scgi www-data && usermod -a -G rtorrent rtorrent-scgi

## Get ruTorrent
RUN cd /srv && mkdir rutorrent
WORKDIR /srv/rutorrent
RUN git clone https://github.com/Novik/ruTorrent.git public_html
RUN cd public_html && git submodule add https://github.com/autodl-community/autodl-rutorrent.git plugins/autodl_irssi
RUN chown -R www-data: /srv/rutorrent/public_html

## Fix Locations in rutorrent config
RUN sed -i "s#\"php\".*#\"php\"   => '/usr/bin/php',#g" /srv/rutorrent/public_html/conf/config.php
RUN sed -i "s#\"curl\".*#\"curl\"   => '/usr/bin/curl',#g" /srv/rutorrent/public_html/conf/config.php

## Link avconv
RUN ln -s /usr/bin/avconv /usr/bin/ffmpeg

## Setup NGINX
RUN rm /etc/nginx/sites-enabled/default
ADD nginx/default /etc/nginx/sites-enabled/default

## Expose our port
EXPOSE 80

## Runit
RUN mkdir /etc/service/rtorrent
ADD runit/rtorrent /etc/service/rtorrent/run
RUN mkdir /etc/service/php5-fpm
ADD runit/php5-fpm /etc/service/php5-fpm/run
RUN mkdir /etc/service/nginx
ADD runit/nginx /etc/service/nginx/run

## Clean Up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
