# Firefox

Freier Webbrowser von Mozilla, installiert über `programs.firefox` und
konfiguriert über Firefox-Policies.

## Aktivieren

```nix
meineapp.apps.firefox.enable = true;
```

## Einstellungen

| Option         | Typ  | Standard       | Beschreibung                                              |
|----------------|------|----------------|-----------------------------------------------------------|
| `telemetry`    | bool | `false`        | Nutzungsdaten und Studien an Mozilla senden.              |
| `homepage`     | str  | `"about:home"` | Seite, die beim Start geöffnet wird.                      |
| `searchEngine` | enum | `"DuckDuckGo"` | `"Google"`, `"DuckDuckGo"`, `"Bing"` oder `"Wikipedia (en)"`. |
