{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../users/ted
    ../../users/ted/modules/caddy.nix
    ../../users/ted/modules/grafana.nix
    ../../users/ted/modules/jelly-metrics.nix
    ../../users/ted/modules/jellyfin.nix
    ../../users/ted/modules/macos-process-exporter.nix
    ../../users/ted/modules/node-exporter.nix
    ../../users/ted/modules/prometheus.nix
  ];

  system.stateVersion = 7;

  networking =
    let
      hostName = baseNameOf (toString ./.);
    in
    {
      inherit hostName;
      computerName = hostName;
    };

  home-manager.users.ted.home.packages = with pkgs; [
    qbittorrent
  ];

  power = {
    restartAfterFreeze = true;
    restartAfterPowerFailure = true;

    sleep = {
      allowSleepByPowerButton = false;
      computer = "never";
      display = 5;
      harddisk = "never";
    };
  };

  system.defaults.dock.persistent-apps =
    let
      userPackages =
        name:
        lib.findFirst (
          pkg: (builtins.parseDrvName pkg.name).name == name
        ) null config.home-manager.users.ted.home.packages;
      userPrograms = name: (builtins.getAttr name config.home-manager.users.ted.programs).package;
    in
    map (app: { inherit app; }) [
      "/Applications/Firefox.app/"
      "/Applications/Bitwarden.app/"
      "${userPrograms "ghostty"}/Applications/Ghostty.app/"
      "${userPackages "qbittorrent"}/Applications/qbittorrent.app/"
    ];
}
