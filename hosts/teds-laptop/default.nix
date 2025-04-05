{
  inputs,
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

  nix.linux-builder = {
    enable = true;
    maxJobs = 2;

    config.virtualisation = {
      darwin-builder = {
        diskSize = 50 * 1024;
        memorySize = 14 * 1024;
      };
    };

    systems = with inputs.flake-utils.lib.system; [
      aarch64-linux
      x86_64-linux
    ];
  };
}
