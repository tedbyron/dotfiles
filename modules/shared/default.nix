{
  self,
  pkgs,
  ...
}:
{
  imports = [ ./nix.nix ];

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

    shells = with pkgs; [
      bashInteractive
      zsh
    ];

    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      diffutils
      findutils
      gawk
      gnugrep
      gnused
      groff
      less
      nmap
      openssl
      python3
    ];
  };
}
