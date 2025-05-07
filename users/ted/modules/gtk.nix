{ lib, ... }:
let
  inherit (lib.ted) readConfig;
  fromGtkSettings = p: readConfig p |> builtins.fromTOML |> builtins.getAttr "Settings";
in
{
  gtk = {
    enable = true;
    gtk2.extraConfig = readConfig ".gtkrc-2.0";
    gtk3.extraConfig = fromGtkSettings "gtk-3.0/settings.ini";
    gtk4.extraConfig = fromGtkSettings "gtk-4.0/settings.ini";
  };
}
