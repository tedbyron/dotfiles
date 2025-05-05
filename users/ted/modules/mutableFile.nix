{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.mutableFile;

  runtimeInputs = lib.makeBinPath (
    with pkgs;
    [
      coreutils
      curl
      git
    ]
  );

  fetchScript =
    _: v:
    let
      url = lib.escapeShellArg v.url;
      path = lib.escapeShellArg v.path;
      extraArgs = lib.escapeShellArgs v.extraArgs;
    in
    {
      git = "[[ -d ${path} ]] || git clone ${extraArgs} ${url} ${path}";
      fetch = "[[ -e ${path} ]] || curl ${extraArgs} ${url} --output ${path}";
      custom = "[[ -e ${path} ]] || ${extraArgs}";
    };

  fileType =
    baseDir:
    {
      name,
      options,
      ...
    }:
    {
      options = {
        url = lib.mkOption { type = lib.types.str; };

        path = lib.mkOption {
          type = lib.types.str;
          default = name;
          apply = p: if lib.hasPrefix "/" p then p else "${baseDir}/${p}";
        };

        type = lib.mkOption {
          type = lib.types.enum [
            "git"
            "fetch"
            "custom"
          ];
          default = "fetch";
        };

        extraArgs = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];
        };

        postScript = lib.mkOption {
          type = lib.types.lines;
          description = ''
            A shell script fragment to be executed after the download.
          '';
          default = "";
          example = lib.literalExpression ''
            ''${config.xdg.configHome}/emacs/bin/doom install --no-config --no-fonts --install --force
          '';
        };
      };
    };
in
{
  options.home.mutableFile = lib.mkOption {
    type = with lib.types; attrsOf (submodule (fileType config.home.homeDirectory));
    default = { };
  };

  config = lib.mkIf (cfg != { }) {
    systemd.user.services.fetch-mutable-files = {
      Unit = {
        Description = "Fetch mutable home-manager files";
        After = [
          "default.target"
          "network-online.target"
        ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        PrivateUsers = true;
        PrivateTmp = true;

        Type = "oneshot";
        RemainAfterExit = true;

        ExecStart =
          let
            mutableFilesCmds = lib.mapAttrsToList (
              _: value:
              let
                url = lib.escapeShellArg value.url;
                path = lib.escapeShellArg value.path;
              in
              ''
                (
                  URL=${url}
                  FILEPATH=${path}
                  DIRNAME=$(dirname ${path})
                  mkdir -p "$DIRNAME"
                  ${(fetchScript path value).${value.type}}
                )
              ''
            ) cfg;

            shellScript = pkgs.writeShellScriptBin "fetch-mutable-files" ''
              export PATH=${runtimeInputs}''${PATH:-:$PATH}
              ${lib.concatStringsSep "\n" mutableFilesCmds}
            '';
          in
          lib.getExe shellScript;

        ExecStartPost =
          let
            mutableFilesCmds = lib.mapAttrsToList (_: value: value.postScript) cfg;

            shellScript = pkgs.writeShellScriptBin "fetch-mutable-files-post-script" ''
              export PATH=${runtimeInputs}''${PATH:-:$PATH}
              ${lib.concatStringsSep "\n" mutableFilesCmds}
            '';
          in
          lib.getExe shellScript;
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
