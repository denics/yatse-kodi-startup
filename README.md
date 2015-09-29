# Wake up your Kodi box using Yatse!
This script allows you to start [kodi](http://kodi.tv/about/) on your media center using [yatse](http://yatse.tv/redmine/projects/yatse) as a remote controller. Once it is running, the script will be listening to any upcomming WoL message to run the command to start kodi service.

The script has been successfully tested on rasbian, archlinux ARM (raspberry pi), debian and ubuntu.

## Add the Start/Stop Script to init.d

```
sudo cp yatse /etc/init.d/yatse
sudo chmod +x /etc/init.d/yatse
```

## Copy the script to usr

```
sudo cp yatse.pl /usr/local/bin/yatse
sudo chmod +x /usr/local/bin/yatse
```

### Make sure you have the dependences

The script is written in perl so be sure you have `perl` properly insalled before continuing.

Also, since it needs to deal with proccess' ids (PIDs) the script uses the perl module `File::Pid`. Two ways of installing it depending on the distribution you are running.

#### On Debian-based distros

```
sudo aptitude install libfile-pid-perl
```

#### Others*

*verify `make` and `perl` are also installed before running it

```
perl -MCPAN -e 'install File::Pid'
```

## Use the script
```
sudo service yatse (start|stop|status)
```

### Start the script on starting (you want it!)
```
update-rc.d yatse defaults 99
```
