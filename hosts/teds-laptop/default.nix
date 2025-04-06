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

  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/linux-builder.log";
      StandardErrorPath = "/var/log/linux-builder.log";
    };
  };

  networking = {
    computerName = name;
    hostName = name;
  };

  nix.linux-builder = with inputs.flake-utils.lib.system; {
    enable = true;
    maxJobs = 4;

    # NOTE: linux-builder should be run once before using `config`.
    # nix build --impure --expr '(with import <nixpkgs> { system = "aarch64-linux"; }; runCommand "uname" {} "uname -a > $out")'
    config = {
      boot.binfmt.emulatedSystems = [ x86_64-linux ];
      nix.settings.sandbox = false;

      virtualisation = {
        darwin-builder = {
          diskSize = 50 * 1024;
          memorySize = 14 * 1024;
        };
      };
    };

    supportedFeatures = [
      "kvm"
      "benchmark"
      "big-parallel"
      "nixos-test"
    ];

    systems = [
      aarch64-linux
      x86_64-linux
    ];
  };
}
