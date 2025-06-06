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

    home =
      let
        emacsDir = "${config.xdg.configHome}/emacs";
      in
      {
        sessionPath = [ "${emacsDir}/bin" ];

        sessionVariables = {
          DOOMDIR = "${config.xdg.configHome}/doom";
          EMACS = "${lib.getExe package}";
          EMACSDIR = emacsDir;
        };

        mutableFile."${config.xdg.configHome}/emacs" = {
          type = "git";
          url = "https://github.com/doomemacs/doomemacs.git";

          extraArgs = [
            "--depth=1"
            "--filter=tree:0"
          ];

          postScript =
            let
              doom = "${emacsDir}/bin/doom";
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

    xdg.configFile.doom = {
      source = lib.ted.configPath "doom";
      recursive = true;
    };

    programs.zsh.initExtra = ''
      e()     { pgrep emacs && emacsclient -n $@ || emacs -nw $@ }
      ediff() emacs -nw --eval "(ediff-files \"$1\" \"$2\")"
      eman()  emacs -nw --eval "(switch-to-buffer (man \"$1\"))"
      ekill() emacsclient --eval '(kill-emacs)'
    '';
  };
}
