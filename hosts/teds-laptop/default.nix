{ config, pkgs, ... }:
{
  imports = [ ../../users/ted ];

  system.stateVersion = 5;

  networking =
    let
      hostName = baseNameOf (toString ./.);
    in
    {
      inherit hostName;
      computerName = hostName;
    };

  homebrew.casks = [
    "discord"
  ];

  home-manager.users.ted.home.packages = with pkgs; [
    qbittorrent
  ];

  system.defaults.dock.persistent-apps =
    let
      inherit (config.home-manager.users.ted.programs.spicetify) spicedSpotify;

      # userPackages =
      #   name:
      #   lib.findFirst (
      #     pkg: (builtins.parseDrvName pkg.name).name == name
      #   ) null config.home-manager.users.ted.home.packages;
      userPrograms = name: (builtins.getAttr name config.home-manager.users.ted.programs).package;
    in
    builtins.map (app: { inherit app; }) [
      "/Applications/Firefox.app/"
      "/Applications/Bitwarden.app/"
      "${spicedSpotify}/Applications/Spotify.app/"
      "/Applications/Discord.app/"
      "${userPrograms "alacritty"}/Applications/Alacritty.app/"
      # "${userPrograms "ghostty"}/Applications/Ghostty.app/"
      "${userPrograms "vscode"}/Applications/Visual Studio Code.app/"
    ];

  # custom.dock =
  #   let
  #     inherit (config.home-manager.users.ted.programs.spicetify) spicedSpotify;

  #     userPackages =
  #       name:
  #       lib.findFirst (
  #         pkg: (builtins.parseDrvName pkg.name).name == name
  #       ) null config.home-manager.users.ted.home.packages;
  #     userPrograms = name: (builtins.getAttr name config.home-manager.users.ted.programs).package;
  #   in
  #   {
  #     enable = true;

  #     entries =
  #       map (path: { inherit path; }) [
  #         "/Applications/Firefox.app/"
  #         "/Applications/Bitwarden.app/"
  #         "${spicedSpotify}/Applications/Spotify.app/"
  #         "${userPackages "discord"}/Applications/Discord.app/"
  #         "${userPrograms "alacritty"}/Applications/Alacritty.app/"
  #         # "${userPrograms "ghostty"}/Applications/Ghostty.app/"
  #         "${userPrograms "vscode"}/Applications/Visual Studio Code.app/"
  #       ]
  #       ++ [
  #         {
  #           path = "${config.users.users.ted.home}/Downloads/";
  #           section = "others";
  #           options = "--display stack --view auto --sort dateadded";
  #         }
  #       ];
  #   };

  # launchd.daemons.linux-builder = {
  #   serviceConfig = {
  #     StandardOutPath = "/var/log/linux-builder.log";
  #     StandardErrorPath = "/var/log/linux-builder.log";
  #   };
  # };

  # nix.linux-builder = with inputs.utils.lib.system; {
  #   enable = true;
  #   ephemeral = true;
  #   maxJobs = 4;

  #   # NOTE: linux-builder should be run once before using `config`.
  #   # nix build --impure --expr '(with import <nixpkgs> { system = "aarch64-linux"; }; runCommand "uname" {} "uname -a > $out")'
  #   config = {
  #     boot.binfmt.emulatedSystems = [ x86_64-linux ];
  #     nix.settings.sandbox = false;

  #     virtualisation = {
  #       darwin-builder = {
  #         diskSize = 50 * 1024;
  #         memorySize = 14 * 1024;
  #       };
  #     };
  #   };

  #   supportedFeatures = [
  #     "kvm"
  #     "benchmark"
  #     "big-parallel"
  #     "nixos-test"
  #   ];

  #   systems = [
  #     aarch64-linux
  #     x86_64-linux
  #   ];
  # };
}
