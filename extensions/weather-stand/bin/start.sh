#!/bin/sh

cd "$(dirname "$0")"

# Shutdown as many services as possible
/etc/init.d/framework stop
/etc/init.d/powerd stop
/etc/init.d/phd stop
/etc/init.d/volumd stop
/etc/init.d/lipc-daemon stop
/etc/init.d/tmd stop
/etc/init.d/webreaderd stop
/etc/init.d/browserd stop
killall lipc-wait-event
/etc/init.d/pmond stop
/etc/init.d/cron stop
sleep 5

# Clean up display, show initialisation message
/usr/sbin/eips -c
/usr/sbin/eips -c
/usr/sbin/eips 11 18 'Kindle Weather Stand Project'
/usr/sbin/eips 15 19 'https://git.io/vDVgT'
/usr/sbin/eips 19 21 'Initialising...'

if [ -d /mnt/debian/bin ]; then  # Check if image file exists
    echo "[*] Debian image already mounted!"
else
    echo "[*] Mount debian image"
	mount -o loop -t ext3 /mnt/us/debian.ext3 /mnt/debian
	echo "[*] Preparing Filesystem..."
	mount -o bind /dev /mnt/debian/dev  # Mount /dev
	mount -o bind /proc /mnt/debian/proc  # Mount /proc
	mount -o bind /sys /mnt/debian/sys  # Mount /sys
	echo "[*] Preparing Network..."
	cp /etc/hosts /mnt/debian/etc/hosts # Copy host systems host file
	cp /etc/resolv.conf /mnt/debian/etc/resolv.conf  # Copy systems DNS config
fi

while true
do
    # Enable WiFi
    /usr/bin/lipc-set-prop com.lab126.wifid enable 1
    sleep 60
    
    # Update weather
    ./weather-manager.sh
    
    # Disable WiFi, set wakeup alarm then back to sleep
    # Alarm is in seconds, so 3600 means it will wake it self up every hour
    /usr/bin/lipc-set-prop com.lab126.wifid enable 0
    sleep 15
    echo "" > /sys/class/rtc/rtc0/wakealarm
    # Following line contains sleep time in seconds
    # Use +3600 (1hr) for Dark Sky API, and +10800 (3hrs) for OpenWeatherMap API
    echo "+3600" > /sys/class/rtc/rtc0/wakealarm
    # Following line will put device into deep sleep until the alarm above is triggered
    echo mem > /sys/power/state
done
