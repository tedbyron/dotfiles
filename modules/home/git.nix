{ config, pkgs, ... }:
{
  delta.enable = true;
  enable = true;

  extraConfig = {
    core = {
      eol = "lf";
      pager = "${pkgs.delta}/bin/delta";
    };

    diff.colorMoved = "default";

    fetch = {
      parallel = 0;
      prune = true;
    };

    init.defaultBranch = "main";
    interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
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
}
