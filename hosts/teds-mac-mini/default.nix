{ config, ... }:
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
      userPrograms = name: (builtins.getAttr name config.home-manager.users.ted.programs).package;
    in
    map (app: { inherit app; }) [
      "/Applications/Firefox.app/"
      "/Applications/Bitwarden.app/"
      "${userPrograms "ghostty"}/Applications/Ghostty.app/"
      "${userPrograms "vscode"}/Applications/Visual Studio Code.app/"
    ];
}
