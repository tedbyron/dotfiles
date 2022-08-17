{ pkgs, ... }:
{
  environment = {
    loginShell = pkgs.zsh;
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
    cleanup = "zap";
    enable = true;
    global = {
      brewfile = true;
      noLock = true;
    };
    masApps = { };
    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/core"
      "homebrew/services"
    ];
  };

  nix = {
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    extraOptions =
      ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      '';
    package = pkgs.nixUnstable;
    trustedUsers = [ "root" "@admin" ];
  };

  nixpkgs.config.allowUnfree = true;

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
        SecondClickThreshold = 0;
        TrackpadRightClick = false;
        TrackpadThreeFingerDrag = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # pam.enableSudoTouchIdAuth = true;

    stateVersion = 4;
  };

  users.nix.configureBuildUsers = true;
}
