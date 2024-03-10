final: prev: {
  oh-my-zsh = prev.oh-my-zsh.overrideAttrs (oldAttrs: {
    src = prev.fetchFromGitHub {
      owner = prev.oh-my-zsh.src.owner;
      repo = prev.oh-my-zsh.src.repo;
      rev = prev.oh-my-zsh.src.rev;
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
