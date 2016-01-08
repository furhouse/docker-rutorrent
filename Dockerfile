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
RUN useradd rtorrent \
    && mkdir /home/rtorrent

## Create group for rTorrent unix socket
RUN groupadd rtorrent-scgi

## Create group for ruTorrent to access files it needs
RUN groupadd rtorrent-webaccess

## Add rtorrent and www-data to rTorrent socket/web access group
RUN usermod -a -G rtorrent-scgi www-data && usermod -a -G rtorrent-scgi rtorrent && usermod -a -G rtorrent-webaccess www-data && usermod -a -G rtorrent-webaccess rtorrent

## Get ruTorrent
RUN cd /srv && mkdir rutorrent
WORKDIR /srv/rutorrent
RUN git clone https://github.com/Novik/ruTorrent.git public_html
RUN cd public_html && git submodule add https://github.com/autodl-community/autodl-rutorrent.git plugins/autodl-irssi
ADD rutorrent/conf.php /srv/rutorrent/public_html/plugins/autodl-irssi/conf.php
RUN chown -R www-data: /srv/rutorrent/public_html

## Fix Locations in rutorrent config
RUN sed -i "s#\"php\".*#\"php\"   => '/usr/bin/php',#g" /srv/rutorrent/public_html/conf/config.php
RUN sed -i "s#\"curl\".*#\"curl\"   => '/usr/bin/curl',#g" /srv/rutorrent/public_html/conf/config.php
RUN sed -i "s#scgi_port = 5000#scgi_port = 0#g" /srv/rutorrent/public_html/conf/config.php
RUN sed -i 's#scgi_host = "127.0.0.1"#scgi_host = "unix:///home/rtorrent/scgi.socket"#g' /srv/rutorrent/public_html/conf/config.php

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

## Setup rtorrent
ADD rtorrent/rtorrentrc /home/rtorrent/.rtorrent.rc
RUN mkdir -p /home/rtorrent/.rtorrent/session
RUN mkdir -p /home/rtorrent/Downloads
RUN mkdir -p /home/rtorrent/Torrents
RUN chown rtorrent: /home/rtorrent
RUN chown rtorrent:rtorrent-webaccess /home/rtorrent/Downloads /home/rtorrent/Torrents /home/rtorrent/.rtorrent/session

## Setup autodl-irssi
USER rtorrent
RUN mkdir -p /home/rtorrent/.irssi/scripts/autorun
WORKDIR /home/rtorrent/.irssi/scripts
RUN curl -sL http://git.io/vlcND | grep -Po '(?<="browser_download_url": ")(.*-v[\d.]+.zip)' | xargs wget --quiet -O autodl-irssi.zip
RUN unzip -o autodl-irssi.zip && rm autodl-irssi.zip && cp autodl-irssi.pl autorun/ && mkdir -p /home/rtorrent/.autodl
ADD irssi/autodl.cfg /home/rtorrent/.autodl/autodl.cfg

## Expose our port
EXPOSE 80

## Clean Up
USER root
WORKDIR /root
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
