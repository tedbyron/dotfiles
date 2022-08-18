{ lib, ... }:
let inherit (lib) mkOption types;
in
{
  options.user = {
    description = mkOption {
      type = with types; nullOr string;
      default = null;
      description = "Account owner's full name";
    };

    email = mkOption {
      type = with types; nullOr string;
      default = null;
      description = "Account email address";
    };

    name = mkOption {
      type = with types; nullOr string;
      default = null;
      description = "Account username";
    };

    key = mkOption {
      type = with types; nullOr string;
      default = null;
      description = "GPG signing key";
    };
  };
}
