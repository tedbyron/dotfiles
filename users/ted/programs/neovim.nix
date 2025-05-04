{
  pkgs,
  unstable,
  ...
}:
{
  programs.neovim = {
    enable = true;
    package = unstable.neovim-unwrapped.overrideAttrs { inherit (pkgs.neovim-unwrapped) meta; }; # TODO: 25.05
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
  };
}
