#!/bin/sh

cd "$(dirname "$0")"

# Weather source
python weather-generator-openweathermap.py

# The script should output a svg file in tmp directory, check before conversion
if [ -e /mnt/debian/tmp/weather-latest.svg ]; then
    chroot /mnt/debian /usr/bin/rsvg-convert --background-color=white -o /tmp/weather-converted.png /tmp/weather-latest.svg
    rm -f /mnt/debian/tmp/weather-latest.svg
    chroot /mnt/debian /usr/bin/pngcrush -c 0 /tmp/weather-converted.png /tmp/weather-crushed.png
    rm -f /mnt/debian/tmp/weather-converted.png
    exit 0;
else
    exit 1;
fi
