#! /bin/bash

#################################################################################
#echo "change password for user pi from standard >>raspberry<< to an more secure:"
#passwd pi

#################################################################################
echo "install mc & x11vnc"
apt-get update
apt-get -y install mc x11vnc

echo "ask for Password for x11vnc"
x11vnc -storepasswd

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
# writing
# @xset s noblank
# @xset s off
# @xset -dpms
# to
# /etc/xdg/lxsession/LXDE-pi/autostart or/and
# /etc/xdg/lxsession/LXDE/autostart
# did not work

file= /etc/lightdm/lightdm.conf
if [ ! -f $file".original" ]; 
then
	cp $file $file".original"
fi
sed -e "{
	/#xserver-command=X/ s/#xserver-command=X/xserver-command=X -s 0 -dpms/
}" -i $file


#################################################################################
echo "copy restartChromium.sh to /usr/local/bin/restartChromium.sh"

cp files/restartChromium.sh /usr/local/bin/restartChromium.sh

chown root:staff /usr/local/bin/restartChromium.sh
chmod 755 /usr/local/bin/restartChromium.sh

#################################################################################
echo "create cronjob in /etc/cron.hourly"

echo "
#!/bin/bash
export DISPLAY=:0
XAUTHORITY=/home/pi/.Xauthority
su -c '/usr/local/bin/restartChromium.sh' pi
" >> /etc/cron.hourly/restartChromium

chown root:root /etc/cron.hourly/restartChromium
chmod 755 /etc/cron.hourly/restartChromium

#################################################################################
echo "
install Desktop-Files for automatic startup of:
x11vnc remote control
&
Chromium
"
mkdir .config/autostart

echo "[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=x11vnc
Comment=
Exec=x11vnc -forever -usepw -httpport 5900
StartupNotify=false
Terminal=false
Hidden=false
" >> .config/autostart/x11vnc.desktop

echo "[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Chromium-Starter
Comment=
Exec=/usr/local/bin/restartChromium.sh
StartupNotify=false
Terminal=false
Hidden=false
" >> .config/autostart/Chromium-Starter.desktop

chown -v -R pi:pi .config/autostart


