{ lib, pkgs, ... }:
{
  environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";

  nix.binaryCaches = [ "https://cache.nixos.org/" ];
  nix.binaryCachePublicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  nix.extraOptions =
    ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  nix.trustedUsers = [ "root" "@admin" ];

  services.nix-daemon.enable = true;
  /*
    services.yabai.enable = true;
    services.yabai.config = {
    focus_follows_mouse = "autoraise";
    mouse_follows_focus = "off";
    window_placement    = "second_child";
    window_opacity      = "off";
    top_padding         = 36;
    bottom_padding      = 10;
    left_padding        = 10;
    right_padding       = 10;
    window_gap          = 10;
    };
  */

  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = true;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
  system.defaults.NSGlobalDomain._HIHideMenuBar = false;
  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
  system.defaults.NSGlobalDomain."com.apple.sound.beep.volume" = 0.6065307;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.NSGlobalDomain."com.apple.trackpad.enableSecondaryClick" = true;
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 2.0;
  system.defaults.alf.allowdownloadsignedenabled = 1;
  system.defaults.alf.globalstate = 1;
  system.defaults.alf.stealthenabled = 1;
  system.defaults.dock.autohide = true;
  system.defaults.dock.expose-group-by-app = false;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "bottom";
  system.defaults.dock.show-recents = false;
  system.defaults.dock.tilesize = 64;
  system.defaults.dock.wvous-bl-corner = 1;
  system.defaults.dock.wvous-br-corner = 1;
  system.defaults.dock.wvous-tl-corner = 1;
  system.defaults.dock.wvous-tr-corner = 1;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.AppleShowAllFiles = false;
  system.defaults.finder.CreateDesktop = false;
  system.defaults.finder.FXDefaultSearchScope = "SCcf";
  system.defaults.finder.FXPreferredViewStyle = "clmv";
  system.defaults.finder.ShowStatusBar = true;
  system.defaults.finder._FXShowPosixPathInTitle = true;
  system.defaults.loginwindow.GuestEnabled = false;
  system.defaults.magicmouse.MouseButtonMode = "TwoButton";
  system.defaults.screencapture.disable-shadow = true;
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.FirstClickThreshold = 0;
  system.defaults.trackpad.SecondClickThreshold = 0;
  system.defaults.trackpad.TrackpadRightClick = false;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  users.nix.configureBuildUsers = true;
}
