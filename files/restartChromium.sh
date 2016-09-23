#! /bin/bash

# URLs for "Supplierplan"
URL_01="https://asopo.webuntis.com/WebUntis/monitor?school=brg-app&monitorType=subst&format=Schueler_2_Tage"
URL_02="https://asopo.webuntis.com/WebUntis/monitor?school=gfb-app&monitorType=subst&format=Schueler_2_Tage"
#URL_02="http://www.abendgym.tsn.at"
# Starttime for URL_01
# Show always URL_01 or URL_02
# STARTTIME_URL_01=0 && STARTTIME_URL_02=24 => always display URL_01 
# STARTTIME_URL_01=24 && STARTTIME_URL_02=0 => always display URL_02 
STARTTIME_URL_01=5
STARTTIME_URL_02=17


# Programname and program options
START_COMMAND="chromium-browser"
#OPTIONS="--kiosk --no-default-browser-check --disable-translate"
OPTIONS="--start-fullscreen --no-default-browser-check --disable-translate"

CURRENT_HOUR=$(date +%H)
#for testing: 
CURRENT_HOUR="5"
if [ "$CURRENT_HOUR" -ge "$STARTTIME_URL_01" ] && [ "$CURRENT_HOUR" -lt "$STARTTIME_URL_02" ];
then
	URL_OK=$URL_01
	URL_KO=$URL_02
else
	URL_OK=$URL_02
	URL_KO=$URL_01
fi

# check, if Browser is running with wrong URL
BROWSER_PID=$(ps ax | grep -e "$START_COMMAND" | grep -e "$URL_KO" | cut --delimiter=' ' --field=2)
# restart browser, if running with wrong URL
if [ ! "$BROWSER_PID" = "" ];
then
	echo "Browser with wrong URL: $URL_KO, we stop it"
	kill -INT $BROWSER_PID
	echo "starting Browser with URL: $URL_OK"
	$START_COMMAND $OPTIONS $URL_OK &
fi
# check, if browser was startet at all
BROWSER_PID=$(ps ax | grep -e "$START_COMMAND" | grep -e "$URL_OK" | cut --delimiter=' ' --field=2)
if [ "$BROWSER_PID" = "" ];
then
	echo "starting Browser with URL: $URL_OK"
	$START_COMMAND $OPTIONS $URL_OK &
fi
