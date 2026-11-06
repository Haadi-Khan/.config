#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["icalendar>=6", "recurring-ical-events>=3", "google-auth-oauthlib>=1.2"]
# ///
"""Print calendar events between two dates as JSON, for the quickshell drawer.

Usage:
    events.py YYYY-MM-DD YYYY-MM-DD     events in range (start incl., end excl.)
    events.py login you@example.com     sign in to a Google account (opens browser)

Calendars are listed in ~/.config/quickshell/calendars.conf, one per line:
    Name = https://calendar.google.com/calendar/ical/.../basic.ics
    Name = ~/path/to/local.ics
    Name = google:you@example.com        every calendar ticked in Google Calendar

Google sign-in needs an OAuth client (Desktop app) saved as
~/.config/quickshell/google-client.json; tokens live in
~/.local/share/quickshell/google/. Remote data is cached in
~/.cache/quickshell/calendars (ICS: 10 min, Google: 5 min).
"""

import datetime as dt
import hashlib
import json
import sys
import urllib.parse
import urllib.request
from pathlib import Path

CONF = Path.home() / ".config/quickshell/calendars.conf"
CACHE = Path.home() / ".cache/quickshell/calendars"
GOOGLE_CLIENT = Path.home() / ".config/quickshell/google-client.json"
GOOGLE_TOKENS = Path.home() / ".local/share/quickshell/google"
GOOGLE_SCOPES = ["https://www.googleapis.com/auth/calendar.readonly"]
GOOGLE_API = "https://www.googleapis.com/calendar/v3"
ICS_TTL = 600
GOOGLE_TTL = 300
PALETTE = ["#61afef", "#c678dd", "#98c379", "#e5c07b", "#e06c75", "#56b6c2"]


def read_conf():
    cals = []
    if not CONF.exists():
        return cals
    for line in CONF.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        name, _, src = line.partition("=") if "=" in line and not line.startswith("http") else ("", "", line)
        cals.append((name.strip() or f"Calendar {len(cals) + 1}", src.strip()))
    return cals


def cached(key, ttl, produce):
    """Return produce() (bytes), cached under key; serve stale data when offline."""
    CACHE.mkdir(parents=True, exist_ok=True)
    path = CACHE / hashlib.sha1(key.encode()).hexdigest()
    if path.exists() and dt.datetime.now().timestamp() - path.stat().st_mtime < ttl:
        return path.read_bytes()
    try:
        data = produce()
        path.write_bytes(data)
        return data
    except Exception:
        if path.exists():
            return path.read_bytes()
        raise


def to_local(v):
    if isinstance(v, dt.datetime):
        return (v if v.tzinfo else v.astimezone()).astimezone()
    return v


# ── ICS feeds / files ────────────────────────────────────────────────────────

def ics_events(name, src, color, start, end):
    import icalendar
    import recurring_ical_events

    if src.startswith(("http://", "https://", "webcal://")):
        url = src.replace("webcal://", "https://", 1)

        def download():
            req = urllib.request.Request(url, headers={"User-Agent": "quickshell-drawer"})
            with urllib.request.urlopen(req, timeout=15) as r:
                return r.read()

        data = cached(url, ICS_TTL, download)
    else:
        data = Path(src).expanduser().read_bytes()

    cal = icalendar.Calendar.from_ical(data)
    for ev in recurring_ical_events.of(cal).between(start, end):
        s = to_local(ev.get("DTSTART").dt)
        e_prop = ev.get("DTEND")
        e = to_local(e_prop.dt) if e_prop else None
        all_day = not isinstance(s, dt.datetime)
        if e is None:
            e = s + (dt.timedelta(days=1) if all_day else dt.timedelta(0))
        yield {
            "title": str(ev.get("SUMMARY", "(No title)")),
            "location": str(ev.get("LOCATION", "")),
            "start": s.isoformat(),
            "end": e.isoformat(),
            "allDay": all_day,
            "calendar": name,
            "color": color,
            "url": str(ev.get("URL", "")),
        }


# ── Google Calendar API ──────────────────────────────────────────────────────

def token_path(account):
    return GOOGLE_TOKENS / f"{account}.json"


def google_login(account):
    from google_auth_oauthlib.flow import InstalledAppFlow

    if not GOOGLE_CLIENT.exists():
        sys.exit(f"Missing OAuth client: save it as {GOOGLE_CLIENT}")
    flow = InstalledAppFlow.from_client_secrets_file(str(GOOGLE_CLIENT), GOOGLE_SCOPES)
    creds = flow.run_local_server(
        port=0, login_hint=account, prompt="consent",
        authorization_prompt_message="Opening your browser to sign in to Google…\n{url}\n",
        success_message="Signed in. You can close this tab and return to the terminal.",
    )
    GOOGLE_TOKENS.mkdir(parents=True, exist_ok=True)
    path = token_path(account)
    path.write_text(creds.to_json())
    path.chmod(0o600)
    print(f"Saved token for {account} to {path}")


def google_session(account):
    from google.auth.transport.requests import AuthorizedSession, Request
    from google.oauth2.credentials import Credentials

    path = token_path(account)
    if not path.exists():
        raise RuntimeError(f"not signed in — run: ~/.config/quickshell/scripts/events.py login {account}")
    creds = Credentials.from_authorized_user_file(str(path), GOOGLE_SCOPES)
    if not creds.valid:
        creds.refresh(Request())
        path.write_text(creds.to_json())
    return AuthorizedSession(creds)


def google_get_all(session, url, params):
    items, params = [], dict(params)
    while True:
        r = session.get(url, params=params, timeout=15)
        r.raise_for_status()
        body = r.json()
        items += body.get("items", [])
        if not body.get("nextPageToken"):
            return items
        params["pageToken"] = body["nextPageToken"]


def google_fetch(account, start, end):
    session = google_session(account)
    tz_start = dt.datetime.combine(start, dt.time()).astimezone().isoformat()
    tz_end = dt.datetime.combine(end, dt.time()).astimezone().isoformat()
    out = []
    calendars = google_get_all(session, f"{GOOGLE_API}/users/me/calendarList", {"minAccessRole": "reader"})
    for cal in calendars:
        if not cal.get("selected") or cal.get("hidden"):
            continue  # only calendars ticked in Google Calendar's sidebar
        events = google_get_all(
            session,
            f"{GOOGLE_API}/calendars/{urllib.parse.quote(cal['id'])}/events",
            {"timeMin": tz_start, "timeMax": tz_end, "singleEvents": "true",
             "orderBy": "startTime", "maxResults": 2500},
        )
        out.append({"calendar": cal.get("summaryOverride") or cal.get("summary", ""),
                    "color": cal.get("backgroundColor"), "primary": bool(cal.get("primary")),
                    "events": events})
    return json.dumps(out).encode()


def google_events(name, account, start, end):
    data = cached(f"google:v2:{account}:{start}:{end}", GOOGLE_TTL, lambda: google_fetch(account, start, end))
    seen = set()
    # Your own calendar first, so a meeting shared with a colleague's calendar
    # you also show is listed once, under yours.
    for cal in sorted(json.loads(data), key=lambda c: not c.get("primary")):
        for ev in cal["events"]:
            if ev.get("status") == "cancelled":
                continue
            # Other people's "working from Home/Office" markers aren't events for you.
            if ev.get("eventType") == "workingLocation" and not cal.get("primary"):
                continue
            key = (ev.get("iCalUID") or ev.get("id"), json.dumps(ev.get("start"), sort_keys=True))
            if key in seen:
                continue
            seen.add(key)
            me = next((a for a in ev.get("attendees", []) if a.get("self")), None)
            if me and me.get("responseStatus") == "declined":
                continue
            s, e = ev["start"], ev["end"]
            all_day = "date" in s
            if all_day:
                start_s, end_s = s["date"], e["date"]
            else:
                start_s = dt.datetime.fromisoformat(s["dateTime"]).astimezone().isoformat()
                end_s = dt.datetime.fromisoformat(e["dateTime"]).astimezone().isoformat()
            yield {
                "title": ev.get("summary", "(No title)"),
                "location": ev.get("location", ""),
                "start": start_s,
                "end": end_s,
                "allDay": all_day,
                "calendar": cal["calendar"] or name,
                "color": cal["color"] or PALETTE[0],
                "url": ev.get("hangoutLink") or ev.get("htmlLink", ""),
            }


# ── main ─────────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) == 3 and sys.argv[1] == "login":
        google_login(sys.argv[2])
        return

    start = dt.date.fromisoformat(sys.argv[1])
    end = dt.date.fromisoformat(sys.argv[2])
    cals = read_conf()
    out = {"events": [], "errors": [], "configured": bool(cals)}

    for i, (name, src) in enumerate(cals):
        try:
            if src.startswith("google:"):
                out["events"] += google_events(name, src.removeprefix("google:").strip(), start, end)
            else:
                out["events"] += ics_events(name, src, PALETTE[i % len(PALETTE)], start, end)
        except Exception as exc:
            out["errors"].append(f"{name}: {exc}")

    out["events"].sort(key=lambda x: (x["start"][:10], not x["allDay"], x["start"]))
    json.dump(out, sys.stdout)


if __name__ == "__main__":
    main()
