{
  config,
  pkgs,
  lib,
  darwin,
  ...
}:
{
  home.file = {
    ".hushlogin" = {
      enable = darwin;
      text = "";
    };

    "${config.programs.gpg.homedir}/gpg-agent.conf" = {
      enable = true;
      onChange = "${lib.getBin pkgs.gnupg}/bin/gpgconf --kill gpg-agent";

      text = ''
        allow-preset-passphrase
        default-cache-ttl 34560000
        max-cache-ttl 34560000
      ''
      + lib.optionalString darwin ''
        pinentry-program ${pkgs.pinentry_mac}/${pkgs.pinentry_mac.binaryPath}
      '';
    };

    # firefoxChrome =
    #   let
    #     profilesDir = "${home}/Library/Caches/Firefox/Profiles";
    #     # Dir read is impure.
    #     releaseProfile = lib.optionalString (builtins.pathExists profilesDir) (
    #       lib.findFirst (name: lib.hasSuffix ".default-release" name) "" (
    #         builtins.attrNames (builtins.readDir profilesDir)
    #       )
    #     );
    #   in
    #   {
    #     enable = darwin && releaseProfile != "";
    #     source = ../../config/firefox/chrome;
    #     target = "Library/Caches/Firefox/Profiles/${releaseProfile}/chrome";
    #   };
  };

  xdg = {
    enable = true;

    configFile = {
      "fastfetch/config.jsonc".source = lib.ted.configPath "fastfetch/config.jsonc";
      "iex/.iex.exs".source = lib.ted.configPath "iex/.iex.exs";
      "just/justfile".source = ../../justfile;
      "nvim/init.lua".source = lib.ted.configPath "nvim/init.lua";
      "python/pythonrc.py".source = lib.ted.configPath "python/pythonrc.py";
      "rustfmt.toml".source = lib.ted.configPath "rustfmt.toml";
      "stylua.toml".source = lib.ted.configPath "stylua.toml";
      "tio/config".source = lib.ted.configPath "tio/config";

      "nvim/lua" = {
        source = lib.ted.configPath "nvim/lua";
        recursive = true;
      };

      pam-gnupg = {
        enable = !darwin;
        source = lib.ted.configPath "pam-gnupg";
      };
    };
  };
}
