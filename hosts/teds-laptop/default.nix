{
  config,
  lib,
  pkgs,
  ...
}:
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
          pkg: (lib.parseDrvName pkg.name).name == name
        ) null config.home-manager.users.${user}.home.packages;
      userPrograms = name: (lib.getAttr name config.home-manager.users.${user}.programs).package;
    in
    {
      enable = true;

      entries =
        map (path: { path = path; }) [
          "/Applications/Firefox.app/"
          "/Applications/Bitwarden.app/"
          "${spicedSpotify}/Applications/Spotify.app/"
          "${userPackages "discord"}/Applications/Discord.app/"
          "${userPackages "obsidian"}/Applications/Obsidian.app/"
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

  home-manager.users.${user}.home.packages = with pkgs; [
    discord
    qbittorrent
  ];

  homebrew.casks = [
    "microsoft-teams"
  ];

  networking = {
    computerName = name;
    hostName = name;
  };
}
