## docker-rutorent
A easy to deploy, simple way to deploy rtorrent, rutorrent, and autodl-irssi.

### Usage
```
docker run -t rutorrent --name rutorrent
```

### Additional Fun
#### Custom settings
The default settings file is /home/rtorrent/.rtorrent.rc
You can get a copy from rtorrent/rtorrentrc (in this repo)
All options are changeable except for the rtorrent sessions directory and the location of the socket file.
#### Downloads folder
Mount /home/rtorrent/Downloads somewhere to get access to your Downloads
#### Adding torrents outside of rutorrent and autodl-irssi
Mount /home/rtorrent/Torrents somewhere and place files into the folder. Torrents placed into the folder will be imported automatically
#### Security
Some security aspects were designed into the container. They are as follows.
  - Restricted access to rtorrent socket file. The rtorrent socket file is only accessible by the group 'rtorrent-scgi' or the rtorrent user.
  - Restricted access to rtorrent home folder. Rutorrent can only edit the sessions folder, and the Downloads folder. This is controlled by the group 'rtorrent-webaccess'
