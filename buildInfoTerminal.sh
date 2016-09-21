#! /bin/bash

#################################################################################
echo "install mc"
apt update
apt -y install mc

#################################################################################
echo "change password for user pi from standard >>raspberry<< to an more secure:"
passwd pi

#################################################################################
echo "change keyboard setting for virtual terminals to german:"
file=/etc/default/keyboard
if [ ! -f $file".original" ]; 
then
	cp $file $file".original"
fi

sed -e "{
	/XKBLAYOUT=/ s/XKBLAYOUT=\"gb\"/XKBLAYOUT=\"de\"/
}" -i $file

#################################################################################
echo "stop screensaver"
file=/etc/xdg/lxsession/LXDE-pi/autostart
if [ ! -f $file".original" ]; 
then
	cp $file $file".original"
fi

sed -e "{
	/@xscreensaver -no-splash/ s/@xscreensaver -no-splash/# @xscreensaver -no-splash/
}" -i $file

echo "
@xset s noblank
@xset s off
@xset -dpms
" >> $file

#################################################################################
echo "copy restartChromium.sh to /usr/local/bin/restartChromium.sh"

cp files/restartChromium.sh /usr/local/bin/restartChromium.sh
chown root:root /usr/local/bin/restartChromium.sh
chmod 755 /usr/local/bin/restartChromium.sh

#################################################################################
echo "create cronjob in /etc/cron.hourly"

echo "
#!/bin/bash
export DISPLAY=:0
XAUTHORITY=/home/pi/.Xauthority
su -c '/usr/local/bin/restartChromium.sh' pi
" >> /etc/cron.hourly/restartChromium.cron.sh

