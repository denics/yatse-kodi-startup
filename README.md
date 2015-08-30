# Wake up your Kodi box using Yatse!
This script allow you to wake up your kodi using a yatse remote. 

I have tested it in rasbian (raspberry pi), debian and ubuntu.

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
```
sudo aptitude install libfile-pid-perl
```

## Use the script
```
sudo service yatse (start|stop|status)
```

### Start the script on starting (you want it!)
```
update-rc.d yatse defaults 99
```
