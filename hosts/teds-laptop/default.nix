{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
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
      "mullvad-vpn"
      "steam"
    ];

    masApps = {
      "DaVinci Resolve" = 571213070;
    };
  };

  environment.etc."nix/nix.conf".text = lib.mkAfter ''
    extra-substituters = ssh-ng://ted@teds-mac-mini?ssh-key=/etc/nix/mini-cache_ed25519&trusted=true
    fallback = true
  '';

  home-manager.users.ted.home.packages = with pkgs; [
    unstable.jellyfin-desktop # TODO: 26.11 old hydra build failed
    qbittorrent
  ];

  programs.ssh = {
    extraConfig = ''
      Host teds-mac-mini
        HostName 192.168.2.2
        HostKeyAlias teds-mac-mini
        ConnectTimeout 3
    '';

    knownHosts.teds-mac-mini = {
      hostNames = [ "teds-mac-mini" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoLoThmAw9bdLGUhv7iQcg0/XLS90dUZmHGqypaNoDk";
    };
  };

  system = {
    activationScripts.postActivation.text = ''
      if [[ ! -f /etc/nix/mini-cache_ed25519 ]]; then
        /usr/bin/ssh-keygen -q -t ed25519 -N "" -C root@teds-laptop -f /etc/nix/mini-cache_ed25519
      fi
    '';

    defaults.dock.persistent-apps =
      let
        # userPackages =
        #   name:
        #   lib.findFirst (
        #     pkg: (builtins.parseDrvName pkg.name).name == name
        #   ) null config.home-manager.users.ted.home.packages;
        # The copies made by home-manager's copyApps, which is what Spotlight and
        # Finder open; pointing at the store path gives a second dock icon.
        hmApp =
          name:
          let
            hm = config.home-manager.users.ted;
          in
          "${hm.home.homeDirectory}/${hm.targets.darwin.copyApps.directory}/${name}.app/";
      in
      map (app: { inherit app; }) [
        "/Applications/Firefox.app/"
        "/Applications/Bitwarden.app/"
        "/Applications/Spotify.app/"
        "/Applications/Discord.app/"
        (hmApp "Ghostty")
        (hmApp "Visual Studio Code")
        "/Applications/Affinity.app/"
        "/Applications/DaVinci Resolve.app/"
        "/Applications/Steam.app/"
        (hmApp "Jellyfin Desktop")
      ];
  };

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
