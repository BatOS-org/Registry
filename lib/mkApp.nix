# Turns an app file into a NixOS module.
# Every app automatically gets an enable switch, its settings become real
# options under meineapp.apps.<id>.*, and its config only applies when it is enabled.
{ lib }:
id: app:
{ config, pkgs, ... }:
let
  cfg = config.meineapp.apps.${id};
in
{
  options.meineapp.apps.${id} = {
    enable = lib.mkEnableOption app.name;
  } // (app.settings or { });

  config = lib.mkIf cfg.enable (app.config { inherit cfg pkgs lib; });
}
