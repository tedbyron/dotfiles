{
  self,
  pkgs,
  system,
  ...
}:
{
  imports = [ ./nix.nix ];

  fonts.packages = [ self.outputs.packages.${system}.curlio-ttf ];
  system.configurationRevision = self.rev or self.dirtyRev or null;

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
