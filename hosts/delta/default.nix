{ config, lib, ... }:
let
  name = baseNameOf (toString ./.);
  user = "ted";
in
{
  imports = [ ../../users/${user} ];

  system.stateVersion = 4;

  # TODO dock: move to user, conditional config.networking.hostName
  custom.dock =
    let
      inherit (userPrograms.spicetify) spicedSpotify;

      userPackages = name:
        lib.findFirst
          (pkg: (builtins.parseDrvName pkg.name).name == name)
          null
          config.home-manager.users.${user}.home.packages;
      userPrograms = config.home-manager.users.${user}.programs;
    in
    {
      enable = true;

      entries = map (path: { path = path; }) [
        "/Applications/Firefox.app/"
        "/Applications/Bitwarden.app/"
        "${spicedSpotify}/Applications/Spotify.app/"
        "/Applications/Microsoft Teams (work or school).app/"
        "${userPackages "obsidian"}/Applications/Obsidian.app/"
        "/Applications/VMware Fusion.app/"
        "${userPrograms.alacritty.package}/Applications/Alacritty.app/"
        "${userPrograms.vscode.package}/Applications/Visual Studio Code.app/"
      ] ++ [{
        path = "${config.users.users.${user}.home}/Downloads/";
        section = "others";
        options = "--display stack --view auto --sort dateadded";
      }];
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
