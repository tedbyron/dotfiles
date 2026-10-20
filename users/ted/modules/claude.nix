{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  servers = {
    # Launches the system Firefox with a temporary profile
    firefox-devtools = {
      type = "stdio";
      command = lib.getExe unstable.firefox-devtools-mcp;
      args = [ "--headless" ];
    };
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
}
