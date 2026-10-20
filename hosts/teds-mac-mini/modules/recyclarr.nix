{ pkgs, lib, ... }:
let
  log = "/Users/ted/Library/Logs/recyclarr.log";

  config = pkgs.writeText "recyclarr.yml" ''
    radarr:
      movies:
        base_url: http://127.0.0.1:7878
        api_key: !env_var RADARR_API_KEY

        # MB/minute. TRaSH has no max, and its 1080p Bluray min (50.8) rejects most x265 encodes
        quality_definition:
          type: movie
          qualities: &sizes
            - { name: WEBDL-1080p, min: 12, preferred: 35, max: 80 }
            - { name: WEBRip-1080p, min: 12, preferred: 35, max: 80 }
            - { name: Bluray-1080p, min: 12, preferred: 35, max: 80 }
            - { name: WEBDL-2160p, min: 25, preferred: 100, max: 250 }
            - { name: WEBRip-2160p, min: 25, preferred: 100, max: 250 }
            - { name: Bluray-2160p, min: 25, preferred: 100, max: 250 }

        quality_profiles:
          - trash_id: d1d67249d3890e49bc12e275d989a7e9 # HD Bluray + WEB
            reset_unmatched_scores:
              enabled: true
            upgrade:
              allowed: true
              until_quality: WEB 1080p
              until_score: 2000
          - trash_id: 64fb5f9858489bdac2af690e27c8f42f # UHD Bluray + WEB
            reset_unmatched_scores:
              enabled: true
            upgrade:
              allowed: true
              until_quality: WEB 2160p
              until_score: 2000

        custom_format_groups:
          add:
            - trash_id: a3ac6af01d78e4f21fcb75f601ac96df # [Unwanted] Unwanted Formats
          skip:
            - f8bf8eab4617f12dfdbd16303d8da245 # [Optional] Golden Rule HD
            - ff204bbcecdd487d1cefcefdbf0c278d # [Optional] Golden Rule UHD

        # Prefer x265 over x264; above the top release group tier (1800)
        custom_formats:
          - trash_ids:
              - 9170d55c319f4fe40da8711ba9d8050d # x265
            score: 2000
            assign_scores_to:
              - trash_id: d1d67249d3890e49bc12e275d989a7e9
              - trash_id: 64fb5f9858489bdac2af690e27c8f42f
          - trash_ids:
              - 496f355514737f7d83bf7aa4d24f8169 # TrueHD ATMOS
              - 2f22d89048b01681dde8afe203bf2e95 # DTS X
              - 3cafb66171b47f226146a0770576870f # TrueHD
              - dcf3ec6938fa32445f590a4da84256cd # DTS-HD MA
              - a570d4a0e56a2874b64e5bfa55202a1b # FLAC
              - e7c2fcae07cbada050a0af3357491d7b # PCM
              - 8e109e50e0a0b83a5098b056e13bf6db # DTS-HD HRA
            score: -1000
            assign_scores_to:
              - trash_id: 64fb5f9858489bdac2af690e27c8f42f

    sonarr:
      series:
        base_url: http://127.0.0.1:8989
        api_key: !env_var SONARR_API_KEY

        quality_definition:
          type: series
          qualities: *sizes

        quality_profiles:
          - trash_id: 72dae194fc92bf828f32cde7744e51a1 # WEB-1080p
            reset_unmatched_scores:
              enabled: true
            upgrade:
              allowed: true
              until_score: 2000
          - trash_id: d1498e7d189fbe6c7110ceaabb7473e6 # WEB-2160p
            reset_unmatched_scores:
              enabled: true
            upgrade:
              allowed: true
              until_score: 2000

        custom_format_groups:
          add:
            - trash_id: 74aff4168620ed49dcc67e92b2c2a5b4 # [Optional] Language Profiles
            - trash_id: 85fae4a2294965b75710ef2989c850eb # [Streaming Services] HD/UHD boost
            - trash_id: 59c3af66780d08332fdc64e68297098f # [Unwanted] Unwanted Formats
          skip:
            - 158188097a58d7687dee647e04af0da3 # [Optional] Golden Rule HD
            - e3f37512790f00d0e89e54fe5e790d1c # [Optional] Golden Rule UHD

        custom_formats:
          - trash_ids:
              - c9eafd50846d299b862ca9bb6ea91950 # x265
            score: 2000
            assign_scores_to:
              - trash_id: 72dae194fc92bf828f32cde7744e51a1
              - trash_id: d1498e7d189fbe6c7110ceaabb7473e6
  '';

  apiKey =
    app:
    ''$(${lib.getExe pkgs.gnused} -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' /Users/ted/.local/share/${app}/config.xml)'';

  sync = pkgs.writeShellScript "recyclarr-sync" ''
    export RADARR_API_KEY=${apiKey "radarr"}
    export SONARR_API_KEY=${apiKey "sonarr"}
    exec ${lib.getExe pkgs.recyclarr} sync --config ${config} "$@"
  '';
in
{
  home-manager.users.ted.home.packages = [
    (pkgs.writeShellScriptBin "recyclarr-sync" ''exec ${sync} "$@"'')
  ];

  launchd.user.agents.recyclarr.serviceConfig = {
    ProgramArguments = [ "${sync}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    StartCalendarInterval = [
      {
        Hour = 5;
        Minute = 0;
      }
    ];
  };
}
