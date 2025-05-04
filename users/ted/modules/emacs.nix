{
  config,
  pkgs,
  lib,
  darwin,
  ...
}:
let
  cfg = config.emacs;

  package =
    with pkgs;
    (emacsPackagesFor (if darwin then emacs-macport else emacs-pgtk)).emacsWithPackages (
      epkgs: with epkgs; [
        treesit-grammars.with-all-grammars
        vterm
      ]
    );
in
{
  options.emacs.enable = lib.mkEnableOption "emacs";

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      inherit package;
    };

    services.emacs = {
      enable = true;
      socketActivation.enable = true;
    };

    home = {
      sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];

      sessionVariables = {
        DOOMDIR = "${config.xdg.configHome}/doom";
        EMACS = "${lib.getExe package}";
        EMACSDIR = "${config.xdg.configHome}/emacs";
      };

      mutableFile."${config.xdg.configHome}/emacs" = {
        type = "git";
        url = "https://github.com/doomemacs/doomemacs";

        extraArgs = [
          "--depth=1"
          "--filter=tree:0"
        ];

        postScript =
          let
            doom = "${config.home.sessionVariables.EMACSDIR}/bin/doom";
          in
          ''
            ${doom} install --no-config --no-fonts --force
            ${doom} sync -u --gc --aot --force
          '';
      };

      packages = with pkgs; [
        # :ui doom
        nerd-fonts.symbols-only

        # :checkers spell
        aspell
        aspellDicts.en
        aspellDicts.en-computers
      ];
    };

    xdg.configFile =
      let
        mkLinkConfigPath = path: config.lib.file.mkOutOfStoreSymlink (lib.ted.configPath path);
      in
      {
        "doom/cli.el".source = mkLinkConfigPath "doom/cli.el";
        "doom/config.el".source = mkLinkConfigPath "doom/config.el";
        "doom/init.el".source = mkLinkConfigPath "doom/init.el";
        "doom/packages.el".source = mkLinkConfigPath "doom/packages.el";
      };
  };
}
