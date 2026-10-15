{ pkgs, lib, ... }:
let
  search = key: query: {
    search = null;
    order = "shuffle";
    inherit key query;
  };

  content = {
    movies = search "MOVIES" "type:movie";
    anything = search "ANYTHING" "type:movie OR type:episode";
    comedy = search "COMEDY" "type:episode AND show_genre:comedy";
    drama = search "DRAMA" "type:episode AND show_genre:drama";
    animation = search "ANIMATION" "(type:episode AND show_genre:animation) OR (type:movie AND genre:animation)";
    scifi = search "SCIFI" ''(type:episode AND show_genre:"sci-fi & fantasy") OR (type:movie AND genre:"science fiction")'';
    nineties = search "NINETIES" "(type:movie OR type:episode) AND release_date:[19900101 TO 19991231]";
  };

  loop = c: {
    content = [ c ];
    playout = [
      {
        count = 1;
        content = c.key;
      }
      { repeat = true; }
    ];
  };

  schedules = {
    movies = loop content.movies;
    comedy = loop content.comedy;
    animation = loop content.animation;
    scifi = loop content.scifi;
    nineties = loop content.nineties;
    random = loop content.anything;
  };

  yaml = pkgs.formats.yaml { };
  schema = "${pkgs.ersatztv}/lib/ersatztv/Resources/sequential-schedule.schema.json";

  checked =
    name: value:
    pkgs.runCommand "${name}.yml" { } ''
      ${pkgs.check-jsonschema}/bin/check-jsonschema --schemafile ${schema} ${yaml.generate "${name}.yml" value}
      cp ${yaml.generate "${name}.yml" value} $out
    '';
in
{
  home-manager.users.ted.home.file = lib.mapAttrs' (
    name: value:
    lib.nameValuePair "Library/Application Support/ersatztv/schedules/${name}.yml" {
      source = checked name value;
    }
  ) schedules;
}
