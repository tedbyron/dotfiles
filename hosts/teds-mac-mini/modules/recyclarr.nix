{ pkgs, lib, ... }:
let
  log = "/Users/ted/Library/Logs/recyclarr.log";

  config = pkgs.writeText "recyclarr.yml" ''
    # TRaSH's profiles, scores, sizes and default format groups, unchanged
    # except where noted
    radarr:
      movies:
        base_url: http://127.0.0.1:7878
        api_key: !env_var RADARR_API_KEY
        # Formats dropped from this file are removed from Radarr too
        delete_old_custom_formats: true

        # IDs in folder names let Jellyfin match exactly instead of guessing
        media_naming:
          folder: jellyfin-tmdb
          movie:
            rename: true
            standard: jellyfin-tmdb

        # Override: a lower Bluray-1080p minimum (the guide's is 50.8, ~6 GB
        # for two hours) so the Atmos profile's x265 encodes aren't rejected
        # for size. x265 is rejected in the guide's profile anyway
        quality_definition:
          type: movie
          qualities:
            - name: Bluray-1080p
              min: 25

        # Every guide profile used twice needs a name of its own
        quality_profiles:
          - trash_id: d1d67249d3890e49bc12e275d989a7e9 # HD Bluray + WEB
            name: HD Bluray + WEB
            reset_unmatched_scores:
              enabled: true
          # Added: picked in Seerr's advanced requests by users who want
          # Atmos (see custom_formats). Looser than the guide's: remuxes,
          # Bluray and WEB rank the same, so scores decide, and x265 is a
          # last resort instead of rejected, since many Atmos releases on
          # public trackers are x265 encodes
          - trash_id: d1d67249d3890e49bc12e275d989a7e9 # HD Bluray + WEB
            name: HD Bluray + WEB (Atmos)
            reset_unmatched_scores:
              enabled: true
            min_format_score: -1000
            qualities:
              - name: 1080p
                qualities:
                  - Remux-1080p
                  - Bluray-1080p
                  - WEBDL-1080p
                  - WEBRip-1080p
              - name: Bluray-720p
            upgrade:
              allowed: true
              until_quality: 1080p
              until_score: 10000
          - trash_id: 722b624f9af1e492284c4bc842153a38 # [Anime] Remux-1080p
            reset_unmatched_scores:
              enabled: true

        custom_formats:
          # Guide scores; Atmos beats any non-Atmos release (tiers top out
          # at 1800) and bypasses the 6h delay (1700+)
          - trash_ids:
              - 496f355514737f7d83bf7aa4d24f8169 # TrueHD ATMOS
              - 2f22d89048b01681dde8afe203bf2e95 # DTS X
              - 417804f7f2c4308c1f4c5d380d4c4475 # ATMOS (undefined)
              - 1af239278386be2919e1bcee0bde047e # DD+ ATMOS
            assign_scores_to:
              - name: HD Bluray + WEB (Atmos)
          - trash_ids:
              - dc98083864ea246d05a42df0d05f81cc # x265 (HD)
            assign_scores_to:
              - name: HD Bluray + WEB (Atmos)
                score: -1000

      # Seerr's 4K requests
      movies-4k:
        base_url: http://127.0.0.1:7879
        api_key: !env_var RADARR_4K_API_KEY
        delete_old_custom_formats: true

        media_naming:
          folder: jellyfin-tmdb
          movie:
            rename: true
            standard: jellyfin-tmdb

        quality_definition:
          type: movie

        quality_profiles:
          - trash_id: 64fb5f9858489bdac2af690e27c8f42f # UHD Bluray + WEB
            name: UHD Bluray + WEB
            reset_unmatched_scores:
              enabled: true
          # Added: the guide's profile already scores audio (Atmos first), so
          # this one only adds remuxes, where most TrueHD Atmos is. They rank
          # with Bluray and WEB, so scores decide
          - trash_id: 64fb5f9858489bdac2af690e27c8f42f # UHD Bluray + WEB
            name: UHD Bluray + WEB (Atmos)
            reset_unmatched_scores:
              enabled: true
            qualities:
              - name: 2160p
                qualities:
                  - Remux-2160p
                  - Bluray-2160p
                  - WEBDL-2160p
                  - WEBRip-2160p
            upgrade:
              allowed: true
              until_quality: 2160p
              until_score: 10000

    sonarr:
      series:
        base_url: http://127.0.0.1:8989
        api_key: !env_var SONARR_API_KEY
        delete_old_custom_formats: true

        media_naming:
          series: jellyfin-tvdb
          season: default
          episodes:
            rename: true
            standard: default
            daily: default
            anime: default

        # Override: lower 1080p minimums so x265 encodes (x265 season packs
        # run 8-12 MB/min, under half the guide's minimums) aren't rejected
        # for size
        quality_definition:
          type: series
          qualities:
            - name: Bluray-1080p
              min: 15
            - name: WEBDL-1080p
              min: 8
            - name: WEBRip-1080p
              min: 8

        quality_profiles:
          - trash_id: 72dae194fc92bf828f32cde7744e51a1 # WEB-1080p
            name: WEB-1080p
            reset_unmatched_scores:
              enabled: true
            # Override: x265 is a last resort instead of rejected (see
            # custom_formats), since on public trackers most season packs are
            # x265, and Bluray-1080p ranks with WEB, since packs of older shows
            # are mostly Bluray rips. Every 1080p quality ranks the same, so
            # scores decide: any x264 release beats x265 and replaces it later,
            # and Bluray (no tier scores here) loses to a tiered WEB release
            min_format_score: -1000
            qualities:
              - name: 1080p
                qualities:
                  - WEBRip-1080p
                  - WEBDL-1080p
                  - Bluray-1080p
            upgrade:
              allowed: true
              until_quality: 1080p
              until_score: 10000
          # Added: WEB-1080p with the overrides above, plus Atmos scores (see
          # custom_formats)
          - trash_id: 72dae194fc92bf828f32cde7744e51a1 # WEB-1080p
            name: WEB-1080p (Atmos)
            reset_unmatched_scores:
              enabled: true
            min_format_score: -1000
            qualities:
              - name: 1080p
                qualities:
                  - WEBRip-1080p
                  - WEBDL-1080p
                  - Bluray-1080p
            upgrade:
              allowed: true
              until_quality: 1080p
              until_score: 10000
          - trash_id: 20e0fc959f1f1704bed501f23bdae76f # [Anime] Remux-1080p
            reset_unmatched_scores:
              enabled: true

        custom_formats:
          - trash_ids:
              - 47435ece6b99a0b477caf360e79ba0bb # x265 (HD)
            assign_scores_to:
              - name: WEB-1080p
                score: -1000
              - name: WEB-1080p (Atmos)
                score: -1000
          # Guide scores; Atmos beats any non-Atmos release and bypasses the
          # 6h delay (1700+)
          - trash_ids:
              - 0d7824bb924701997f874e7ff7d4844a # TrueHD ATMOS
              - 9d00418ba386a083fbf4d58235fc37ef # DTS X
              - b6fbafa7942952a13e17e2b1152b539a # ATMOS (undefined)
              - 4232a509ce60c4e208d13825b7c06264 # DD+ ATMOS
            assign_scores_to:
              - name: WEB-1080p (Atmos)
          # Override: the anime profile only rejects dubs named as such
          # (Dubs Only), so English-only releases tagged "ENG" got through
          # and replaced dual-audio copies. Radarr's anime profile already
          # requires the original language
          - trash_ids:
              - ae575f95ab639ba5d15f663bf019e3e8 # Language: Not Original
            assign_scores_to:
              - trash_id: 20e0fc959f1f1704bed501f23bdae76f # [Anime] Remux-1080p
                score: -10000

      # Seerr's 4K requests
      series-4k:
        base_url: http://127.0.0.1:8990
        api_key: !env_var SONARR_4K_API_KEY
        delete_old_custom_formats: true

        media_naming:
          series: jellyfin-tvdb
          season: default
          episodes:
            rename: true
            standard: default
            daily: default
            anime: default

        quality_definition:
          type: series

        quality_profiles:
          - trash_id: d1498e7d189fbe6c7110ceaabb7473e6 # WEB-2160p
            name: WEB-2160p
            reset_unmatched_scores:
              enabled: true
          # Added: Atmos scores, and Bluray encodes (no remuxes) rank with WEB
          - trash_id: d1498e7d189fbe6c7110ceaabb7473e6 # WEB-2160p
            name: WEB-2160p (Atmos)
            reset_unmatched_scores:
              enabled: true
            qualities:
              - name: 2160p
                qualities:
                  - WEBRip-2160p
                  - WEBDL-2160p
                  - Bluray-2160p
            upgrade:
              allowed: true
              until_quality: 2160p
              until_score: 10000

        custom_formats:
          - trash_ids:
              - 0d7824bb924701997f874e7ff7d4844a # TrueHD ATMOS
              - 9d00418ba386a083fbf4d58235fc37ef # DTS X
              - b6fbafa7942952a13e17e2b1152b539a # ATMOS (undefined)
              - 4232a509ce60c4e208d13825b7c06264 # DD+ ATMOS
            assign_scores_to:
              - name: WEB-2160p (Atmos)
  '';

  apiKey =
    app:
    ''$(${lib.getExe pkgs.gnused} -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' /Users/ted/.local/share/${app}/config.xml)'';

  sync = pkgs.writeShellScript "recyclarr-sync" ''
    # At boot this runs before Radarr and Sonarr are up, and a failed run stays
    # failed (and alerting) until 5am
    for _ in $(seq 60); do
      ${lib.getExe pkgs.curl} -sf -o /dev/null http://127.0.0.1:7878/ping \
        && ${lib.getExe pkgs.curl} -sf -o /dev/null http://127.0.0.1:7879/ping \
        && ${lib.getExe pkgs.curl} -sf -o /dev/null http://127.0.0.1:8989/ping \
        && ${lib.getExe pkgs.curl} -sf -o /dev/null http://127.0.0.1:8990/ping \
        && break
      sleep 10
    done

    export RADARR_API_KEY=${apiKey "radarr"}
    export RADARR_4K_API_KEY=${apiKey "radarr-4k"}
    export SONARR_API_KEY=${apiKey "sonarr"}
    export SONARR_4K_API_KEY=${apiKey "sonarr-4k"}
    exec ${lib.getExe pkgs.recyclarr} sync --config ${config} "$@"
  '';
in
{
  launchd.user.agents.recyclarr.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [ "${sync}" ];
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
