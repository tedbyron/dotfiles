{ config, pkgs, unstable, ... }:
let
  inherit (config.home-manager.users.${user}.programs.spicetify) spicedSpotify;

  name = "delta";
  user = "ted";
in
{
  imports = [ ../../users/${user} ];

  system.stateVersion = 4;

  # TODO dock: move to user, conditional config.networking.hostName
  custom.dock = {
    enable = true;

    entries = [
      { path = "/Applications/Firefox.app/"; }
      { path = "/Applications/Bitwarden.app/"; }
      { path = "${spicedSpotify}/Applications/Spotify.app/"; }
      { path = "/Applications/Microsoft Teams (work or school).app/"; }
      { path = "${pkgs.obsidian}/Applications/Obsidian.app/"; }
      { path = "/Applications/VMware Fusion.app/"; }
      { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
      { path = "${unstable.vscode}/Applications/Visual Studio Code.app/"; }
      {
        path = "${config.users.users.${user}.home}/Downloads/";
        section = "others";
        options = "--display stack --view auto --sort dateadded";
      }
    ];
  };

  homebrew.casks = [
    "linearmouse"
    "microsoft-excel"
    "microsoft-teams"
    "microsoft-word"
    "vmware-fusion"
  ];

  networking = {
    computerName = name;
    hostName = name;
  };
}
