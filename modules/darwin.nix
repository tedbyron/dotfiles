{ pkgs, ... }:
{
  environment = {
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    pathsToLink = [ "/usr/share/zsh" ];
    shells = with pkgs; [ bashInteractive zsh ];
    systemPackages = with pkgs; [ ];
  };

  homebrew = {
    brewPrefix =
      if pkgs.stdenvNoCC.isAarch64
      then "/opt/homebrew/bin"
      else "/usr/local/bin";

    brews = [ ];
    casks = [ ];
    enable = true;
    global.brewfile = true;
    masApps = { };

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/core"
      "homebrew/services"
    ];
  };

  nix = {
    configureBuildUsers = true;

    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';

    gc.automatic = true;
    package = pkgs.nixUnstable;

    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://nixpkgs.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      ];

      trusted-users = [ "@admin" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
    man.enable = true;
    nix-index.enable = true;
    zsh.enable = true;
  };

  services.nix-daemon.enable = true;

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = true;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = true;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = false;
        "com.apple.mouse.tapBehavior" = 1;
        # "com.apple.sound.beep.volume" = 0.6065307; # FIXME
        "com.apple.swipescrolldirection" = false;
        "com.apple.trackpad.enableSecondaryClick" = true;
        # "com.apple.trackpad.scaling" = 2.0; # FIXME
      };

      alf = {
        allowdownloadsignedenabled = 1;
        globalstate = 1;
        stealthenabled = 1;
      };

      dock = {
        autohide = true;
        expose-group-by-app = false;
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "bottom";
        show-recents = false;
        tilesize = 64;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "clmv";
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      loginwindow.GuestEnabled = false;
      magicmouse.MouseButtonMode = "TwoButton";
      screencapture.disable-shadow = true;

      trackpad = {
        Clicking = true;
        FirstClickThreshold = 0;
        TrackpadRightClick = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    stateVersion = 4;
  };
}
