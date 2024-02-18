{ self, ... }:
{
  system = {
    configurationRevision = self.rev or self.dirtyRev or null;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      alf.globalstate = 1;
      loginwindow.GuestEnabled = false;
      magicmouse.MouseButtonMode = "TwoButton";
      universalaccess.reduceTransparency = true;

      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        expose-group-by-app = false;
        minimize-to-application = true;
        mru-spaces = false;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      menuExtraClock = {
        Show24Hour = true;
        # FIX: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults.menuExtraClock.ShowDate
        ShowDate = 1;
      };

      trackpad = {
        Clicking = true;
        FirstClickThreshold = 0;
        TrackpadRightClick = true;
      };

      NSGlobalDomain = {
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.swipescrolldirection" = false;
        "com.apple.trackpad.enableSecondaryClick" = true;
        "com.apple.trackpad.scaling" = 1.5;
        "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        AppleScrollerPagingBehavior = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSTableViewDefaultSizeMode = 2;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
      };
    };
  };
}
