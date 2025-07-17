{
  unstable,
  ...
}:
{
  programs.neovim = {
    enable = true;
    package = unstable.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
  };
}
