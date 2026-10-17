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
      "mullvad-vpn"
    ];

    masApps = {
      # Xcode = 497799835;
    };
  };

  system.defaults.dock.persistent-apps =
    let
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
      "/Applications/Figma.app/"
      (hmApp "Ghostty")
      (hmApp "Visual Studio Code")
    ];
}
