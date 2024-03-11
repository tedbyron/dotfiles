final: prev: {
  oh-my-zsh = prev.oh-my-zsh.overrideAttrs (oldAttrs: {
    src =
      let prevSrc = prev.oh-my-zsh.src;
      in prev.fetchFromGitHub {
        owner = prevSrc.owner;
        repo = prevSrc.repo;
        rev = prevSrc.rev;
        sha256 = "";
        sparseCheckout = [
          "lib/completion.zsh"
          "lib/correction.zsh"
          "lib/directories.zsh"
          "lib/history.zsh"
          "plugins/git-lfs/git-lfs.plugin.zsh"
          "plugins/git/git.plugin.zsh"
          "plugins/tmux/tmux.plugin.zsh"
        ];
      };
  });
}
