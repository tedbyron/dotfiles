{
  enable = true;
  brews = [ ];
  taps = [ ];

  casks = [
    "obsidian"
    "rectangle"
    "vlc"
  ];

  masApps = {
    NextDNS = 1464122853;
    Bitwarden = 1352778147;
  };

  onActivation = {
    autoUpdate = true;
    cleanup = "zap";
    upgrade = true;
  };
}
