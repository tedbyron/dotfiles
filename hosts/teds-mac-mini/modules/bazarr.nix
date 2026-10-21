{ pkgs, lib, ... }:
let
  dataDir = "/Users/ted/.local/share/bazarr";
  configFile = "${dataDir}/config/config.yaml";
  log = "/Users/ted/Library/Logs/bazarr.log";

  # AnimeTosho moved off animetosho.org (it no longer resolves) and now gives each
  # attachment's download URL and language_code in its API. The AniDB refiner
  # also stores get_episode_ids' (series, episode) pair as the episode ID, so the
  # provider searched by the series ID. Still unfixed upstream as of 1.6.3-beta
  bazarr = pkgs.bazarr.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace custom_libs/subliminal_patch/providers/animetosho.py \
        --replace-fail feed.animetosho.org feed.animetosho.net \
        --replace-fail "storage_download_url + '{}/{}.xz'.format(hex_id, subtitle_file['id'])" "subtitle_file['url']" \
        --replace-fail "subtitle_file['info'].get('lang', 'eng')" "subtitle_file['info'].get('language_code', 'eng')"
      substituteInPlace bazarr/subtitles/refiners/anidb.py \
        --replace-fail "anidb_episode_id = anidb_client.get_episode_ids(" "_, anidb_episode_id = anidb_client.get_episode_ids("
    '';
  });

  start = pkgs.writeShellScript "start-bazarr" ''
    until [ -d /Volumes/media/movies ]; do
      echo "waiting for /Volumes/media"
      sleep 5
    done

    mkdir -p ${dataDir}/config
    touch ${configFile}
    ${lib.getExe pkgs.yq-go} -i '.general.ip = "127.0.0.1" | .general.port = 6767' ${configFile}

    # A child left behind by a killed wrapper keeps the port, so every new
    # child exits on bind while the orphan serves stale code
    /usr/bin/pkill -9 -f "bazarr/main.py --config ${dataDir}" || true

    export PATH=${lib.makeBinPath [ pkgs.ffmpeg ]}:$PATH
    exec ${bazarr}/bin/bazarr --config ${dataDir} --no-update
  '';
in
{
  launchd.user.agents.bazarr.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = lib.ted.waitForNix [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
  };
}
