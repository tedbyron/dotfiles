{ config, lib, ... }:
let
  name = baseNameOf (toString ./.);
  user = "ted";
in
{
  imports = [ ../../users/${user} ];

  system.stateVersion = 5;

  custom.dock =
    let
      inherit (config.home-manager.users.${user}.programs.spicetify) spicedSpotify;

      userPackages =
        name:
        lib.findFirst (
          pkg: (builtins.parseDrvName pkg.name).name == name
        ) null config.home-manager.users.${user}.home.packages;
      userPrograms = name: (builtins.getAttr name config.home-manager.users.${user}.programs).package;
    in
    {
      enable = true;

      entries =
        map (path: { path = path; }) [
          "/Applications/Firefox.app/"
          "/Applications/Bitwarden.app/"
          "${userPackages "obsidian"}/Applications/Obsidian.app/"
          "${spicedSpotify}/Applications/Spotify.app/"
          "/Applications/Microsoft Teams.app/"
          "/Applications/Figma.app/"
          "/Applications/VMware Fusion.app/"
          "${userPrograms "alacritty"}/Applications/Alacritty.app/"
          "${userPrograms "vscode"}/Applications/Visual Studio Code.app/"
        ]
        ++ [
          {
            path = "${config.users.users.${user}.home}/Downloads/";
            section = "others";
            options = "--display stack --view auto --sort dateadded";
          }
        ];
    };

  homebrew.casks = [
    "ba-connected"
    "figma"
    "lunar"
    "meetingbar"
    "microsoft-teams"
    "vmware-fusion"
  ];

  networking = {
    computerName = name;
    hostName = name;
  };
}
