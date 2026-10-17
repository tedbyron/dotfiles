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
    christmas = search "CHRISTMAS" ''(type:movie AND (tag:christmas OR tag:"christmas party" OR tag:"santa claus" OR title:christmas OR title:xmas)) OR (type:episode AND (title:christmas OR title:xmas OR tag:christmas))'';
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
    christmas = loop content.christmas;
  };

  yaml = pkgs.formats.yaml { };
  schema = "${pkgs.ersatztv}/lib/ersatztv/Resources/sequential-schedule.schema.json";

  validate = pkgs.writeText "validate-schedule.py" ''
    import json, sys, jsonschema, yaml

    class Loader(yaml.SafeLoader):
        pass

    def scalar(loader, node):
        v = node.value
        if v == "":
            return None
        if v.lower() in ("true", "false"):
            return v.lower() == "true"
        for cast in (int, float):
            try:
                return cast(v)
            except ValueError:
                pass
        return v

    for tag in ("null", "bool", "int", "float", "str", "timestamp"):
        Loader.add_constructor("tag:yaml.org,2002:" + tag, scalar)

    schema = json.load(open(sys.argv[1]))
    doc = yaml.load(open(sys.argv[2]), Loader=Loader)
    errors = [e.message for e in jsonschema.Draft202012Validator(schema).iter_errors(doc)]
    if errors:
        sys.exit("\n".join(errors))
  '';

  python = pkgs.python3.withPackages (p: [
    p.jsonschema
    p.pyyaml
  ]);

  checked =
    name: value:
    pkgs.runCommand "${name}.yml" { } ''
      sed 's/: null$/:/' ${yaml.generate "${name}.yml" value} > $out
      ${python}/bin/python3 ${validate} ${schema} $out
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
