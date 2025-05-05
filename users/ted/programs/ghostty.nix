{ lib, ... }:
{
  programs.ghostty = {
    enable = false;
    enableZshIntegration = true;
    installBatSyntax = true;
    settings = builtins.fromTOML (lib.ted.readConfig "ghostty/config");

    themes = {
      gruvbox-material-dark = {
        background = "#282828";
        foreground = "#d4be98";
        cursor-color = "#d4be98";
        cursor-text = "#282828";
        selection-background = "#45403d";
        selection-foreground = "#d4be98";

        palette = [
          "0=#282828"
          "1=#ea6962"
          "2=#a9b665"
          "3=#d8a657"
          "4=#7daea3"
          "5=#d3869b"
          "6=#89b482"
          "7=#a89984"
          "8=#928374"
          "9=#ea6962"
          "10=#a9b665"
          "11=#d8a657"
          "12=#7daea3"
          "13=#d3869b"
          "14=#89b482"
          "15=#d4be98"
        ];
      };

      gruvbox-material-light = {
        background = "#fbf1c7";
        foreground = "#654735";
        cursor-color = "#654735";
        cursor-text = "#fbf1c7";
        selection-background = "#eee0b7";
        selection-foreground = "#654735";

        palette = [
          "0=#fbf1c7"
          "1=#c14a4a"
          "2=#6c782e"
          "3=#b47109"
          "4=#45707a"
          "5=#945e80"
          "6=#4c7a5d"
          "7=#7c6f64"
          "8=#928374"
          "9=#c14a4a"
          "10=#6c782e"
          "11=#b47109"
          "12=#45707a"
          "13=#945e80"
          "14=#4c7a5d"
          "15=#654735"
        ];
      };
    };
  };
}
