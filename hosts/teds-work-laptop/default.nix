{ config, ... }:
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
      "figma"
      "meetingbar"
      "protonvpn"
    ];

    masApps = {
      # Xcode = 497799835;
    };
  };

  system.defaults.dock.persistent-apps =
    let
      userPrograms = name: (builtins.getAttr name config.home-manager.users.ted.programs).package;
    in
    map (app: { inherit app; }) [
      "/Applications/Zen.app/"
      "/Applications/Bitwarden.app/"
      "/Applications/Spotify.app/"
      "/Applications/Figma.app/"
      "${userPrograms "ghostty"}/Applications/Ghostty.app/"
      "${userPrograms "vscode"}/Applications/Visual Studio Code.app/"
    ];
}
