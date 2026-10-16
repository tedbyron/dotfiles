{ config, unstable, ... }:
{
  imports = [
    ../../users/ted
    ../../users/ted/modules/media
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

  services.openssh.enable = true;

  environment.etc = {
    "nix/nix.conf".enable = false;

    "nix/nix.custom.conf".text = ''
      download-buffer-size = 536870912
      extra-experimental-features = auto-allocate-uids pipe-operators
      extra-substituters = https://cachix.cachix.org https://nix-community.cachix.org
      extra-trusted-public-keys = cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
      trusted-users = root @admin
    '';
  };

  home-manager.users.ted.home.packages = [
    unstable.jellyfin-desktop # TODO: 26.11 old hydra build failed
  ];

  power = {
    restartAfterFreeze = true;
    restartAfterPowerFailure = true;

    sleep = {
      allowSleepByPowerButton = false;
      computer = "never";
      display = 10;
      harddisk = "never";
    };
  };

  system.defaults.dock.persistent-apps =
    let
      userPrograms = name: (builtins.getAttr name config.home-manager.users.ted.programs).package;
    in
    map (app: { inherit app; }) [
      "/Applications/Firefox.app/"
      "/Applications/Bitwarden.app/"
      "${userPrograms "ghostty"}/Applications/Ghostty.app/"
      "${userPrograms "vscode"}/Applications/Visual Studio Code.app/"
    ];

  users.users.ted.openssh.authorizedKeys.keys = [
    ''restrict,command="/nix/var/nix/profiles/default/bin/nix-daemon --stdio" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ03cN9i+T95Ohp9DXgDDL38xDKfUQ/T/y+6TdwOaR62 root@teds-laptop''
  ];
}
