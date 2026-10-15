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

  homebrew = {
    casks = [
      "affinity"
      "discord"
      "steam"
    ];

    masApps = {
      "DaVinci Resolve" = 571213070;
    };
  };

  home-manager.users.ted.home.packages = with pkgs; [
    qbittorrent
  ];

  system.defaults.dock.persistent-apps =
    let
      # userPackages =
      #   name:
      #   lib.findFirst (
      #     pkg: (builtins.parseDrvName pkg.name).name == name
      #   ) null config.home-manager.users.ted.home.packages;
      userPrograms = name: (builtins.getAttr name config.home-manager.users.ted.programs).package;
    in
    map (app: { inherit app; }) [
      "/Applications/Firefox.app/"
      "/Applications/Bitwarden.app/"
      "/Applications/Spotify.app/"
      "/Applications/Discord.app/"
      "${userPrograms "ghostty"}/Applications/Ghostty.app/"
      "${userPrograms "vscode"}/Applications/Visual Studio Code.app/"
      "/Applications/Affinity.app/"
      "/Applications/DaVinci Resolve.app/"
      "/Applications/Steam.app/"
    ];

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
