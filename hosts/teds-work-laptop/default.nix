{ config, ... }:
let
  name = baseNameOf (toString ./.);
  user = "ted";
in
{
  imports = [ ../../users/${user} ];

  system.stateVersion = 5;

  networking = {
    computerName = name;
    hostName = name;
  };

  homebrew = {
    casks = [
      "figma"
      "meetingbar"
    ];

    masApps = {
      # Xcode = 497799835;
    };
  };

  custom.dock =
    let
      inherit (config.home-manager.users.${user}.programs.spicetify) spicedSpotify;

      userPrograms = name: (builtins.getAttr name config.home-manager.users.${user}.programs).package;
    in
    {
      enable = true;

      entries =
        map (path: { inherit path; }) [
          "/Applications/Firefox.app/"
          "/Applications/Bitwarden.app/"
          "${spicedSpotify}/Applications/Spotify.app/"
          "/Applications/Figma.app/"
          "${userPrograms "alacritty"}/Applications/Alacritty.app/"
          # "${userPrograms "ghostty"}/Applications/Ghostty.app/"
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
}
