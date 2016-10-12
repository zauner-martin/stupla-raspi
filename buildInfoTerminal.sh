#! /bin/bash

# Make sure only root can run our script
if [ $EUID -ne 0 ];
then
   echo "This script must be run as root"
   exit 1
fi

#################################################################################
echo "install mc & x11vnc"

if [ "$(dpkg -l | grep x11vnc)" = "" ];
then
	apt-get update
	apt-get -y install mc x11vnc

	echo "ask for Password for x11vnc"
	# run x11vnc -storepasswd as user pi
	su -c 'x11vnc -storepasswd' pi
fi



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

file="/etc/lightdm/lightdm.conf"
if [ ! -f $file".original" ]; 
then
	cp $file $file".original"
fi
sed -e "{
	/#xserver-command=X/ s/#xserver-command=X/xserver-command=X -s 0 -dpms/
}" -i $file


#################################################################################
echo "copy kiosk to /home/pi"

cp -R -v kiosk /home/pi
# make pi owner of /home/pi/kiosk
chown -v -R pi:pi /home/pi/kiosk


#################################################################################
echo "
install Desktop-Files for automatic startup of:
x11vnc remote control
&
Chromium
"
AUTOSTARTDIR="/home/pi/.config/autostart"

mkdir $AUTOSTARTDIR

echo "[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=x11vnc
Comment=
Exec=x11vnc -forever -usepw -httpport 5900
StartupNotify=false
Terminal=false
Hidden=false
" >  $AUTOSTARTDIR/x11vnc.desktop

echo "[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Chromium-Starter
Comment=
Exec=chromium-browser --start-fullscreen --no-default-browser-check --disable-translate --disable-session-crashed-bubble --disable-infobars /home/pi/kiosk/kiosk.html
StartupNotify=false
Terminal=false
Hidden=false
" >  $AUTOSTARTDIR/Chromium-Starter.desktop

chown -v -R pi:pi $AUTOSTARTDIR


