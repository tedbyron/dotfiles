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

      text =
        ''
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

    configFile =
      let
        inherit (config.lib.file) mkOutOfStoreSymlink;
        mkLinkConfigPath = path: mkOutOfStoreSymlink (lib.ted.configPath path);
      in
      {
        "iex/.iex.exs".source = mkLinkConfigPath "iex/.iex.exs";
        "just/justfile".source = config.lib.file.mkOutOfStoreSymlink ../../justfile;
        "nvim/init.lua".source = mkLinkConfigPath "nvim/init.lua";
        "rustfmt.toml".source = mkLinkConfigPath "rustfmt.toml";
        "stylua.toml".source = mkLinkConfigPath "stylua.toml";
        "tio/config".source = mkLinkConfigPath "tio/config";

        "nvim/lua" = {
          source = mkLinkConfigPath "nvim/lua";
          recursive = true;
        };

        "pam-gnupg" = {
          enable = !darwin;
          source = lib.ted.configPath "pam-gnupg";
        };
      };
  };
}
