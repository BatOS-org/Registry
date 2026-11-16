{ lib, ... }:
{
  name        = "Firefox";
  description = "Freier Webbrowser von Mozilla.";
  category    = "Internet";
  keywords    = [ "browser" "web" "internet" ];

  settings = {
    telemetry = lib.mkOption {
      type        = lib.types.bool;
      default     = false;
      description = "Ob Firefox Nutzungsdaten an Mozilla sendet.";
    };
    homepage = lib.mkOption {
      type        = lib.types.str;
      default     = "about:home";
      example     = "https://duckduckgo.com";
      description = "Seite, die beim Start geöffnet wird.";
    };
    searchEngine = lib.mkOption {
      type        = lib.types.enum [ "Google" "DuckDuckGo" "Bing" "Wikipedia (en)" ];
      default     = "DuckDuckGo";
      description = "Standard-Suchmaschine.";
    };
  };

  config = { cfg, ... }: {
    programs.firefox.enable = true;
    programs.firefox.policies = {
      DisableTelemetry      = !cfg.telemetry;
      DisableFirefoxStudies = !cfg.telemetry;
      Homepage.URL          = cfg.homepage;
      SearchEngines.Default = cfg.searchEngine;
    };
  };
}
