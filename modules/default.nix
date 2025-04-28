{
  self,
  pkgs,
  darwin,
  ...
}:
{
  imports = [
    (if darwin then ./darwin else ./nixos)
    ./nix.nix
  ];

  system.configurationRevision = self.rev or self.dirtyRev or null;

  fonts.packages = with pkgs; [
    self.outputs.packages.${pkgs.system}.curlio-ttf
    inter
    libre-baskerville
  ];

  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  environment = {
    variables.LANG = "en_US.UTF-8";

    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      diffutils
      expect
      findutils
      gawk
      gnugrep
      gnused
      groff
      less
      moreutils
      nmap
      openssl
      python3
    ];
  };
}
