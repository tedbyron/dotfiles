{ lib, isDarwin, ... }:
{
  imports = [ (if isDarwin then ./darwin else ./nixos) ];

  targets.darwin = lib.optionalAttrs isDarwin {
    currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage = false;
    search = "DuckDuckGo";

    defaults = {
      "com.apple.dock".size-immutable = true;

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "com.apple.Safari" = {
        AutoFillCreditCardData = false;
        AutoFillPasswords = false;
        IncludeDevelopMenu = true;
      };
    };
  };
}
