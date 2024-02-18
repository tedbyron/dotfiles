{
  homebrew = {
    enable = true;
    casks = [ "vlc" ];

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };
}
