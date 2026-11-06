#!/usr/bin/env python3
# Outside temperature for Waybar (custom/weather).
# Location: the first city saved in GNOME Weather (change it there and the bar follows).
# Data: Open-Meteo (no API key). Falls back to the last good reading when offline.
import json
import math
import re
import subprocess
import urllib.request
from pathlib import Path

CACHE = Path.home() / ".cache" / "waybar-weather.json"
FALLBACK = ("Manhattan", 39.18, -96.57)  # used if GNOME Weather has no location

# WMO weather codes -> (description, day icon, night icon); Material Design nerd-font glyphs
SUNNY, NIGHT, PARTLY, CLOUDY, FOG, RAINY, POURING, SNOWY, LIGHTNING = (
    chr(c) for c in (0xF0599, 0xF0594, 0xF0595, 0xF0590, 0xF0591, 0xF0597, 0xF0596, 0xF0598, 0xF0593)
)
CODES = {
    0: ("Clear", SUNNY, NIGHT),
    1: ("Mostly clear", PARTLY, NIGHT),
    2: ("Partly cloudy", PARTLY, PARTLY),
    3: ("Overcast", CLOUDY, CLOUDY),
    45: ("Fog", FOG, FOG), 48: ("Freezing fog", FOG, FOG),
    51: ("Light drizzle", RAINY, RAINY), 53: ("Drizzle", RAINY, RAINY), 55: ("Heavy drizzle", RAINY, RAINY),
    56: ("Freezing drizzle", RAINY, RAINY), 57: ("Freezing drizzle", RAINY, RAINY),
    61: ("Light rain", RAINY, RAINY), 63: ("Rain", RAINY, RAINY), 65: ("Heavy rain", POURING, POURING),
    66: ("Freezing rain", RAINY, RAINY), 67: ("Freezing rain", POURING, POURING),
    71: ("Light snow", SNOWY, SNOWY), 73: ("Snow", SNOWY, SNOWY), 75: ("Heavy snow", SNOWY, SNOWY),
    77: ("Snow grains", SNOWY, SNOWY),
    80: ("Showers", RAINY, RAINY), 81: ("Showers", POURING, POURING), 82: ("Violent showers", POURING, POURING),
    85: ("Snow showers", SNOWY, SNOWY), 86: ("Snow showers", SNOWY, SNOWY),
    95: ("Thunderstorm", LIGHTNING, LIGHTNING), 96: ("Thunderstorm, hail", LIGHTNING, LIGHTNING),
    99: ("Thunderstorm, hail", LIGHTNING, LIGHTNING),
}


def gnome_weather_location():
    """First saved GNOME Weather location as (name, lat, lon); its coords are stored in radians."""
    try:
        out = subprocess.run(["gsettings", "get", "org.gnome.Weather", "locations"],
                             capture_output=True, text=True, timeout=3).stdout
    except (OSError, subprocess.TimeoutExpired):
        return FALLBACK
    m = re.search(r"\('([^']*)', '[^']*', (?:true|false), \[\(([-\d.e]+), ([-\d.e]+)\)\]", out)
    if not m:
        return FALLBACK
    return m.group(1), math.degrees(float(m.group(2))), math.degrees(float(m.group(3)))


def fetch(lat, lon):
    url = ("https://api.open-meteo.com/v1/forecast"
           f"?latitude={lat:.4f}&longitude={lon:.4f}"
           "&current=temperature_2m,apparent_temperature,weather_code,is_day,relative_humidity_2m,wind_speed_10m"
           "&daily=temperature_2m_max,temperature_2m_min&forecast_days=1"
           "&temperature_unit=fahrenheit&wind_speed_unit=mph&timezone=auto")
    with urllib.request.urlopen(url, timeout=10) as r:
        return json.load(r)


def main():
    name, lat, lon = gnome_weather_location()
    try:
        data = fetch(lat, lon)
        cur, day = data["current"], data["daily"]
        desc, day_icon, night_icon = CODES.get(cur["weather_code"], ("Unknown", CLOUDY, CLOUDY))
        out = {
            "text": f"{day_icon if cur['is_day'] else night_icon} {round(cur['temperature_2m'])}°",
            "tooltip": (f"{name}: {desc}\n"
                        f"Feels like {round(cur['apparent_temperature'])}°F\n"
                        f"High {round(day['temperature_2m_max'][0])}° · Low {round(day['temperature_2m_min'][0])}°\n"
                        f"Humidity {cur['relative_humidity_2m']}% · Wind {round(cur['wind_speed_10m'])} mph"),
            "class": "ok",
        }
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(json.dumps(out))
    except Exception:
        try:
            out = json.loads(CACHE.read_text())
            out["class"] = "stale"
            out["tooltip"] += "\n(offline, last known reading)"
        except Exception:
            out = {"text": "", "class": "stale"}
    print(json.dumps(out))


if __name__ == "__main__":
    main()
