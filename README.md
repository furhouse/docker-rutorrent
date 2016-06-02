## docker-rutorent
A easy to deploy, simple way to deploy rtorrent, rutorrent, and autodl-irssi.

### Usage
```
docker-compose up -d
```

### Configuration
To configure rtorrent, edit the settings in data/rtorrent/.rtorrent.rc after the container has started
All options are changeable except for scgi_local, sessions, and the two execute variables at the end of the file.

Open the ports that you want by setting them in data/rtorrent/.rtorrent.rc and adding the ports in docker-compose.yaml

### Downloads folder
The default downloads folder is in  data/rtorrent/Downloads
You can move it somewhere else by creating a symbolic link

### Adding torrents outside of rutorrent and autodl-irssi
The default torrents folder is in data/rtorrent/Torrents

### Security
Some security aspects were designed into the container. They are as follows.
  - Restricted access to rtorrent socket file. The rtorrent socket file is only accessible by the group 'rtorrent-scgi' or the rtorrent user.
  - Restricted access to rtorrent home folder. Rutorrent can only edit the sessions folder, and the Downloads folder. This is controlled by the group 'rtorrent-webaccess'

#### Persistence
  - Rutorrent settings are mounted at data/rutorrent/share
  - The home folder of the rtorrent user is mounted at data/rtorrent
