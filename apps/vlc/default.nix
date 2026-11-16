{ ... }:
{
  name        = "VLC";
  description = "Medienplayer für fast alle Video- und Audioformate.";
  category    = "Multimedia";
  keywords    = [ "video" "audio" "player" "medien" ];

  config = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.vlc ];
  };
}
