#! /bin/bash

# URLs for "Supplierplan"
SUPPL_URL_BRG=www.google.at
SUPPL_URL_GFB=www.novell.com

# Programname and program options
START_COMMAND="chromium-browser"
OPTIONS="--kiosk --no-default-browser-check --disable-translate"

# get current hour and start browser with right url 
# 05 - 16 -> BRG
# 17 - 04 -> GFB

CURRENT_HOUR=$(date +%H)
CURRENT_HOUR="13"
if [ "$CURRENT_HOUR" -ge "5" ] && [ "$CURRENT_HOUR" -lt "17" ];
then
	URL_OK=$SUPPL_URL_BRG
	URL_KO=$SUPPL_URL_GFB
else
	URL_OK=$SUPPL_URL_GFB
	URL_KO=$SUPPL_URL_BRG
fi

# check, if Browser is running with wrong URL
BROWSER_PID=$(ps ax | grep -e "$START_COMMAND" | grep -e $URL_KO | cut --delimiter=' ' --field=2)
# restart browser, if running with wrong URL
if [ ! "$BROWSER_PID" = "" ];
then
	echo "Browser with wrong URL: $URL_KO, we stop it"
	kill -INT $BROWSER_PID
	echo "starting Browser with URL: $URL_OK"
	$START_COMMAND $OPTIONS $URL_OK &
fi
# check, if browser was startet at all
BROWSER_PID=$(ps ax | grep -e "$START_COMMAND" | grep -e $URL_OK | cut --delimiter=' ' --field=2)
if [ "$BROWSER_PID" = "" ];
then
	echo "starting Browser with URL: $URL_OK"
	$START_COMMAND $OPTIONS $URL_OK &
fi
