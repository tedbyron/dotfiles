{
  enable = true;

  settings = {
    format = ''
      ╭ $username$hostname$directory$shlvl$fill $status$cmd_duration$all
      ╰ $character
    '';
    right_format = "";
    scan_timeout = 30;
    command_timeout = 500;
    add_newline = false;

    # Builtin
    battery.format = "[$percentage]($style) ";
    character = {
      format = "$symbol ";
      success_symbol = "[\\$](green)";
      error_symbol = "[\\$](red)";
      vicmd_symbol = "[N](green)";
    };
    cmd_duration = {
      format = "[$duration]($style) ";
      style = "bright-black";
    };
    directory = {
      truncation_length = 5;
      truncate_to_repo = true;
      format = "[$path]($style)[$read_only]($read_only_style) ";
      read_only = " ro";
      style = "cyan";
    };
    fill.symbol = " "; # ─ ━
    hostname = {
      ssh_only = false;
      format = "[$hostname]($style)\\] ";
      style = "yellow";
    };
    jobs.style = "cyan";
    line_break.disabled = true;
    memory_usage = {
      format = "\\[$symbol[$ram( | $swap)]($style)\\] ";
      style = "white";
      disabled = true;
    };
    package = {
      format = "\\[[$symbol$version]($style)\\] ";
      version_format = "\${raw}";
      symbol = "";
      style = "214";
      display_private = true;
      disabled = true;
    };
    shlvl = {
      threshold = 2;
      format = "[$symbol$shlvl]($style) ";
      symbol = "";
      style = "bright-black";
      disabled = false;
    };
    status = {
      format = "[$symbol$status]($style) ";
      symbol = "";
      style = "red";
      disabled = false;
    };
    time = {
      format = "[$time]($style) ";
      time_format = "%R";
      style = "white";
      disabled = true;
    };
    username = {
      style_root = "red";
      style_user = "yellow";
      format = "\\[[$user]($style)@";
      show_always = true;
    };

    # Git
    git_branch = {
      format = "([$symbol$branch]($style) )";
      symbol = ""; # 
      style = "blue";
    };
    git_commit = {
      commit_hash_length = 7;
      format = "[$hash$tag]($style) ";
      tag_symbol = " ";
      style = "white";
      only_detached = false;
    };
    git_state = {
      format = "[$state( $progress_current/$progress_total)]($style) ";
      style = "yellow";
    };
    git_metrics = {
      format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
      added_style = "green";
      deleted_style = "red";
      disabled = false;
    };
    git_status = {
      format = "([$all_status$ahead_behind]($style) )";
      ahead = ">";
      behind = "<";
      diverged = "<>";
      renamed = "r";
      deleted = "x";
      style = "red";
    };

    # Environments
    aws.disabled = true;
    azure.disabled = true;
    buf.disabled = true;
    c.disabled = true;
    cmake.disabled = true;
    cobol.disabled = true;
    conda.disabled = true;
    crystal.disabled = true;
    dart.disabled = true;
    deno.disabled = true;
    docker_context.disabled = true;
    dotnet.disabled = true;
    elixir.disabled = true;
    elm.disabled = true;
    erlang.disabled = true;
    gcloud.disabled = true;
    golang.disabled = true;
    helm.disabled = true;
    java.disabled = true;
    julia.disabled = true;
    kotlin.disabled = true;
    kubernetes.disabled = true;
    lua.disabled = true;
    hg_branch.disabled = true;
    nim.disabled = true;
    nix_shell.disabled = true;
    nodejs.disabled = true;
    ocaml.disabled = true;
    openstack.disabled = true;
    perl.disabled = true;
    php.disabled = true;
    pulumi.disabled = true;
    purescript.disabled = true;
    python.disabled = true;
    rlang.disabled = true;
    red.disabled = true;
    ruby.disabled = true;
    rust.disabled = true;
    scala.disabled = true;
    singularity.disabled = true;
    spack.disabled = true;
    sudo.disabled = true;
    swift.disabled = true;
    terraform.disabled = true;
    vagrant.disabled = true;
    vlang.disabled = true;
    vcsh.disabled = true;
    zig.disabled = true;
  };
}
