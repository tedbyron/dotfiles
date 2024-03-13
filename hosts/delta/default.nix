{ config, pkgs, unstable, lib, ... }:
let
  name = "delta";
  user = "ted";
in
{
  imports = [ ../../users/${user} ];

  system.stateVersion = 4;

  # TODO dock: move to user, conditional config.networking.hostName
  custom.dock =
    let
      inherit (userPrograms.spicetify) spicedSpotify;

      userPkgs = config.home-manager.users.${user}.home.packages;
      getUserPkg = name:
        lib.findFirst
          (pkg: (builtins.parseDrvName pkg.name).name == name)
          null
          userPkgs;
      obsidian = getUserPkg "obsidian";
      userPrograms = config.home-manager.users.${user}.programs;
      alacritty = userPrograms.alacritty.package;
      vscode = userPrograms.vscode.package;
    in
    {
      enable = true;

      entries = [
        { path = "/Applications/Firefox.app/"; }
        { path = "/Applications/Bitwarden.app/"; }
        { path = "${spicedSpotify}/Applications/Spotify.app/"; }
        { path = "/Applications/Microsoft Teams (work or school).app/"; }
        { path = "${obsidian}/Applications/Obsidian.app/"; }
        { path = "/Applications/VMware Fusion.app/"; }
        { path = "${alacritty}/Applications/Alacritty.app/"; }
        { path = "${vscode}/Applications/Visual Studio Code.app/"; }
        {
          path = "${config.users.users.${user}.home}/Downloads/";
          section = "others";
          options = "--display stack --view auto --sort dateadded";
        }
      ];
    };

  homebrew.casks = [
    "lunar"
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
