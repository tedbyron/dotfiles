{ isDarwin }:
let
  inherit (builtins) readFile;
in
{
  programs = {
    alacritty = {
      enable = true;
      settings = fromTOML (readFile ../../.config/alacritty/alacritty.toml);
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FRi";
        theme = "Dracula";
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      # TODO: config
    };

    # TODO: eww

    firefox = {
      enable = true;
      # TODO: config
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      # TODO: config
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;

      settings = {
        git_protocol = "https";
        editor = "code --wait";

        aliases = {
          co = null;
          open = "repo view --web";
        };
      };
    };

    # TODO: gh-dash

    git = {
      enable = true;
      # delta configured in .gitconfig and installed as a user program
      includes.default.contents = readFile ../../.gitconfig;
      ignores = [ ".DS_Store" ];
      lfs.enable = true;
    };

    # TODO: git-cliff

    gpg.enable = true;
    # home-manager.enable = true; #FIX: necessary?
  };
}
