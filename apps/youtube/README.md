# YouTube

Web-App: öffnet https://www.youtube.com in einem eigenen Firefox-Fenster mit
eigenem Profil (`~/.mozilla/webapp-youtube`) und eigenem Startmenü-Eintrag.

## Aktivieren

```nix
meineapp.apps.youtube.enable = true;
```

## Einstellungen

| Option      | Typ          | Standard | Beschreibung                                           |
|-------------|--------------|----------|--------------------------------------------------------|
| `kiosk`     | bool         | `true`   | Vollbild ohne Bedienelemente (Kiosk-Modus).            |
| `extraArgs` | list of str  | `[ ]`    | Zusätzliche Argumente für den Browser, z. B. `--private-window`. |

## Besonderheiten

- Telemetrie und Pocket sind per Firefox-Policy abgeschaltet.
- Pinch-Zoom-Gesten sind deaktiviert (`browser.gesture.pinch.in/out`).
