{ config, pkgs, ... }:
{
  programs = {
    git = {
      delta.enable = true;
      enable = true;

      extraConfig = {
        core.eol = "lf";
        diff.colorMoved = "default";

        fetch = {
          parallel = 0;
          prune = true;
        };

        init.defaultBranch = "main";
        merge.conflictstyle = "diff3";
        pull.ff = "only";

        push = {
          autoSetupRemote = true;
          followTags = true;
        };

        status = {
          short = true;
          showStash = true;
        };

        tag.gpgSign = true;
      };

      ignores = [ ".DS_Store" ];
      lfs.enable = true;

      signing = {
        key = config.user.key;
        signByDefault = true;
      };

      userEmail = config.user.email;
      userName = config.user.description;
    };

    gh = {
      enable = true;
      extensions = [ pkgs.gh-dash ];
    };
  };
}
