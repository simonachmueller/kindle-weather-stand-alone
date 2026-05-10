# Kindle Weather Stand Notes

## Scope

- Project uses OpenWeatherMap only.
- Dark Sky support removed (`weather-generator-darksky.py` deleted).

## Runtime flow

- Main updater: `extensions/weather-stand/bin/weather-manager.sh`
- Generator launcher: `extensions/weather-stand/bin/weather-generator.sh`
- Python generator: `extensions/weather-stand/bin/weather-generator-openweathermap.py`
- SVG template: `extensions/weather-stand/bin/weather-template.svg`

## API key handling

- Do not hardcode OpenWeather key in Python source.
- Use env file on Kindle:
  - `/mnt/us/extensions/weather-stand/bin/.env`
  - `OPENWEATHER_API_KEY=...`
- Shell loads env in `weather-generator.sh` and exports `OPENWEATHER_API_KEY`.
- Python reads key via `os.environ.get("OPENWEATHER_API_KEY", "")`.

## Git safety for secrets

- `.gitignore` includes:
  - `extensions/weather-stand/bin/.env`
- Keep template file for setup:
  - `extensions/weather-stand/bin/.env.example`

## Battery behavior

- Critical battery branch (existing):
  - condition: `BATTERY <= 5` and discharging (`CURRENT <= 0`)
  - behavior: show `CHARGE BATTERY NOW` line via `eips`, skip normal weather render
- Low battery render branch:
  - condition: `BATTERY <= 10` and discharging
  - behavior: render weather image with low-battery SVG icon enabled
- Normal branch:
  - behavior: render weather image with icon hidden

## Battery icon in SVG

- Controlled by token:
  - `VAR_BATTERY_ICON_STYLE` (`display:inline` or `display:none`)
- Final validated placement:
  - `transform="translate(420,36) scale(0.62)"`

## Script reliability notes

- Use absolute eips path in manager script:
  - `EIPS=/usr/sbin/eips`
- Avoid bare `eips` to prevent `eips: not found` in non-interactive script context.

## Quick troubleshooting

1. Check key file exists and has value:
   - `/mnt/us/extensions/weather-stand/bin/.env`
2. Check runtime log:
   - `/tmp/weather-manager-run.log`
3. If `HTTP Error 401`, key invalid/empty/not loaded.
4. If network fails, verify ping path used by script.

## Kindle filesystem reminder

- Rootfs (`/`) is often mounted read-only.
- User storage `/mnt/us` is writable and hosts this extension.
