{
  config,
  lib,
  pkgs,
  unstable,
  darwin,
  ...
}:
let
  servers = {
    # Launches Zen on macOS, the system Firefox elsewhere, with a temporary
    # profile
    firefox-devtools = {
      type = "stdio";
      command = lib.getExe unstable.firefox-devtools-mcp;
      args = [
        "--headless"
      ]
      ++ lib.optionals darwin [
        "--firefoxPath"
        "/Applications/Zen.app/Contents/MacOS/zen"
      ];
    };
  };

  settings = {
    editorMode = "vim";
    theme = "auto";
    inputNeededNotifEnabled = false;
    agentPushNotifEnabled = false;
  };
in
{
  # Claude Code rewrites ~/.claude.json itself, so merge the servers in
  # instead of linking a read-only file
  home.activation.claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    file=${config.home.homeDirectory}/.claude.json
    [ -s "$file" ] || echo '{}' > "$file"
    tmp=$(mktemp "$file.XXXXXX")
    ${lib.getExe pkgs.jq} --argjson servers ${lib.escapeShellArg (builtins.toJSON servers)} \
      '.mcpServers += $servers' "$file" > "$tmp"
    run mv "$tmp" "$file"
  '';

  # Same for settings.json, which /config writes to
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    file=${config.home.homeDirectory}/.claude/settings.json
    mkdir -p "$(dirname "$file")"
    [ -s "$file" ] || echo '{}' > "$file"
    tmp=$(mktemp "$file.XXXXXX")
    ${lib.getExe pkgs.jq} --argjson settings ${lib.escapeShellArg (builtins.toJSON settings)} \
      '. += $settings' "$file" > "$tmp"
    run mv "$tmp" "$file"
  '';
}
