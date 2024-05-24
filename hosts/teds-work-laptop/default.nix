{
  config,
  lib,
  unstable,
  ...
}:
let
  name = baseNameOf (toString ./.);
  user = "ted";
in
{
  imports = [ ../../users/${user} ];

  system.stateVersion = 4;

  custom.dock =
    let
      inherit (config.home-manager.users.${user}.programs.spicetify) spicedSpotify;

      userPackages =
        name:
        lib.findFirst (
          pkg: (builtins.parseDrvName pkg.name).name == name
        ) null config.home-manager.users.${user}.home.packages;
      userPrograms = name: (builtins.getAttr name config.home-manager.users.${user}.programs).package;
    in
    {
      enable = true;

      entries =
        map (path: { path = path; }) [
          "/Applications/Firefox.app/"
          "/Applications/Bitwarden.app/"
          "${userPackages "obsidian"}/Applications/Obsidian.app/"
          "${spicedSpotify}/Applications/Spotify.app/"
          "/Applications/Microsoft Teams (work or school).app/"
          "/Applications/Figma.app/"
          "/Applications/VMware Fusion.app/"
          "/Applications/pgAdmin 4.app/"
          "${userPrograms "alacritty"}/Applications/Alacritty.app/"
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

  home-manager.users.${user}.home.packages = [ unstable.awscli2 ];

  homebrew.casks = [
    "eloston-chromium"
    "figma"
    "lunar"
    "meetingbar"
    "microsoft-teams"
    "pgadmin4"
    "vmware-fusion"
  ];

  networking = {
    computerName = name;
    hostName = name;
  };

  services.postgresql = {
    enable = true;
    authentication = lib.mkForce ''
      #type   database    user    address    auth-method
      local   all         all                trust
    '';
    package = unstable.postgresql;
  };
}
