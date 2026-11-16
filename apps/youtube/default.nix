{ mkWebapp, ... }:
mkWebapp {
  name        = "YouTube";
  description = "Videoplattform als eigenes Fenster.";
  url         = "https://www.youtube.com";
  keywords    = [ "video" "streaming" ];
  kiosk       = true;   # only the default, the user can change it
  policies    = { DisableTelemetry = true; DisablePocket = true; };
  prefs       = {
    "browser.gesture.pinch.in"  = "";
    "browser.gesture.pinch.out" = "";
  };
}
