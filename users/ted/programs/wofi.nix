{ darwin, ... }:
{
  programs.wofi = {
    enable = !darwin;

    settings = {
      width = "25%";
      allow_images = true;
      allow_markup = true;
      hide_scroll = true;
      insensitive = true;
      parse_search = true;
      gtk_dark = true;
      image_size = 16;
      single_click = true;
    };

    style =
      let
        bg = "#282828";
        bg1 = "#3c3836";
        fg = "#ebdbb2";
        orange = "#fe8019";
        borderRadius = "10px";
      in
      ''
        window {
          font-family: system-ui, ui-sans-serif, ui-monospace, sans-serif, monospace;
          background-color: ${bg};
          color: ${fg};
          border-radius: ${borderRadius};
          border: 2px solid ${bg1};
        }

        #input {
          border-radius: ${borderRadius} ${borderRadius} 0 0;
        }

        #input:focus {
          border: 0;
        }

        #entry {
          text-transform: capitalize;
        }

        #entry:selected {
          background-color: ${bg};
          border: 1px solid ${orange};
        }
      '';
  };
}
