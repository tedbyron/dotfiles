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
    ];

    masApps = {
      # Xcode = 497799835;
    };
  };

  custom.dock =
    let
      inherit (config.home-manager.users.ted.programs.spicetify) spicedSpotify;
      userPrograms = name: (builtins.getAttr name config.home-manager.users.ted.programs).package;
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
            path = "${config.users.users.ted.home}/Downloads/";
            section = "others";
            options = "--display stack --view auto --sort dateadded";
          }
        ];
    };
}
