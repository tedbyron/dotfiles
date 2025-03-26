{ self, ... }:
{
  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    startup.chime = false;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      alf.globalstate = 1;
      loginwindow.GuestEnabled = false;
      magicmouse.MouseButtonMode = "TwoButton";

      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        expose-group-apps = false;
        minimize-to-application = true;
        mru-spaces = false;
        tilesize = 56;
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      menuExtraClock = {
        Show24Hour = true;
        ShowDate = 2;
        ShowDayOfWeek = false;
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
        _HIHideMenuBar = true;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        AppleScrollerPagingBehavior = true;
        AppleShowAllExtensions = true;
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
