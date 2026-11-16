# Shortcut for web apps: returns an app structure in the same format as apps/*.nix.
# Every web app runs in its own Firefox profile (~/.mozilla/webapp-<id>)
# and gets its own start menu entry.
{ lib }:
{ id
, name
, url
, description ? "${name} als eigenes Fenster."
, category    ? "Internet"
, keywords    ? [ ]
, icon        ? null
  # Firefox family: "firefox", "firefox-esr", "librewolf"
, browser     ? "firefox"
  # Firefox policies for this web app only (like programs.firefox.policies)
, policies    ? { }
  # about:config settings for this web app only, e.g. { "browser.gesture.pinch.in" = ""; }
, prefs       ? { }
  # Defaults for the user settings
, kiosk       ? false
, extraArgs   ? [ ]
}:
{
  inherit name description category;
  keywords = keywords ++ [ "webapp" ];

  settings = {
    kiosk = lib.mkOption {
      type        = lib.types.bool;
      default     = kiosk;
      description = "Ob ${name} im Vollbild ohne Bedienelemente (Kiosk-Modus) startet.";
    };
    extraArgs = lib.mkOption {
      type        = lib.types.listOf lib.types.str;
      default     = extraArgs;
      example     = [ "--private-window" ];
      description = "Zusätzliche Kommandozeilen-Argumente für den Browser.";
    };
  };

  config = { cfg, pkgs, ... }:
    let
      baseBrowser = lib.attrByPath (lib.splitString "." browser)
        (throw "meineapp: Browser '${browser}' gibt es in nixpkgs nicht")
        pkgs;

      # Separate browser build only if the web app configures something.
      browserPkg =
        if policies == { } && prefs == { } then baseBrowser
        else baseBrowser.override (old: {
          extraPolicies = (old.extraPolicies or { }) // policies;
          extraPrefs = (old.extraPrefs or "") + lib.concatStrings (lib.mapAttrsToList
            (key: value: "lockPref(${builtins.toJSON key}, ${builtins.toJSON value});\n")
            prefs);
        });

      launcher = pkgs.writeShellScriptBin id ''
        PROFILE="$HOME/.mozilla/webapp-"${lib.escapeShellArg id}
        mkdir -p "$PROFILE"
        exec ${lib.getExe browserPkg} \
          --new-instance \
          --profile "$PROFILE" \
          ${lib.optionalString cfg.kiosk "--kiosk"} \
          ${lib.escapeShellArgs cfg.extraArgs} \
          ${lib.escapeShellArg url} "$@"
      '';

      desktopItem = pkgs.makeDesktopItem {
        inherit name icon;
        desktopName = name;
        exec        = "${launcher}/bin/${id}";
        categories  = [ "Network" ];
      };
    in
    {
      environment.systemPackages = [ launcher desktopItem ];
    };
}
