# iex_config = Path.expand("~/.iex.exs")
# if iex_config |> File.exists?() do
#   import iex_config
# end

# :observer.start/0
# runtime_info/0 runtime_info/1
# IEx.configure/1 Inspect.Opts

defmodule ColorHelpers do
  @ansi Application.compile_env(:elixir, :ansi_enabled, true)

  def format(string, color) do
    if @ansi do
      IO.ANSI.format([color, string]) |> IO.chardata_to_string()
    else
      string
    end
  end

  def puts(string, color \\ :default_color) do
    IO.puts(format(string, color))
    IEx.dont_display_result()
  end
end

defmodule H do
  import ColorHelpers

  @home System.user_home!() |> Path.expand()
  @path_separator if elem(:os.type(), 0) == :unix, do: "/", else: "\\"

  # Format the current working directory like fish shell.
  defp cwd do
    case File.cwd() do
      {:ok, cwd} ->
        [dir | rest] =
          Path.expand(cwd)
          |> String.replace(@home, "~", global: false)
          |> String.split("/")
          |> Enum.reverse()

        [dir | Enum.map(rest, &(String.first(&1) || &1))]
        |> Enum.reverse()
        |> Enum.join(@path_separator)

      {:error, _} ->
        "nil"
    end
  end

  defp cwd_color, do: format(cwd(), :cyan)

  # Color the node name and host yellow.
  defp node_color do
    node()
    |> to_string()
    |> String.split("@")
    |> Enum.map(&format(&1, :yellow))
    |> Enum.join("@")
  end

  @caret "\uf0da"
  @caret_color format(@caret, :blue)
  @bullet "\u2219"
  @bullet format(@bullet, :light_black)

  def default_prompt, do: "#{cwd_color()} #{@caret_color}"
  def alive_prompt, do: "#{cwd_color()} #{node_color()} #{@caret_color}"

  def continuation_prompt do
    @bullet <> String.duplicate(" ", String.length("#{cwd()} #{@caret}") - 1)
  end

  def alive_continuation_prompt do
    @bullet <> String.duplicate(" ", String.length("#{cwd()} #{node()} #{@caret}") - 1)
  end

  defp format_app_version(app, color, vsn, puts) do
    s = (to_string(app) |> format(color)) <> format(": #{vsn}", :light_black)

    if puts do
      IO.puts(s)
      IEx.dont_display_result()
    else
      s
    end
  end

  @apps Application.loaded_applications()

  # If `app` is running, returns its name in `color` and version.
  def app_version(app, color \\ :default_color, puts \\ true) do
    with {_, _, vsn} <- Enum.find(@apps, &(elem(&1, 0) == app)) do
      format_app_version(app, color, vsn, puts)
    end
  end

  # If inside a mix app, puts its name and version.
  def mix_app_version(color \\ :default_color, puts \\ true) do
    if function_exported?(Mix.Project, :config, 0) do
      config = Mix.Project.config()

      with app when not is_nil(app) <- Keyword.get(config, :app),
           vsn when not is_nil(vsn) <- Keyword.get(config, :version) do
        format_app_version(app, color, vsn, puts)
      end
    end
  end

  # Extension of `IEx.Helpers.cd/1` to support `to_string/1` types and the `-` param. Updates the
  # `PWD` and `OLDPWD` environment variables, and IEx prompts.
  def cd(directory) do
    directory =
      to_string(directory)
      |> then(
        &with "-" <- &1,
              old_pwd when not is_nil(old_pwd) <- System.get_env("OLDPWD") do
          old_pwd
        else
          <<?~, rest::binary>> -> System.user_home!() <> rest
          _ -> &1
        end
      )

    case File.cwd() do
      {:ok, cwd} -> System.put_env("OLDPWD", cwd)
      {:error, _} -> System.delete_env("OLDPWD")
    end

    case File.cd(directory) do
      :ok ->
        IEx.configure(
          default_prompt: default_prompt(),
          continuation_prompt: continuation_prompt(),
          alive_prompt: alive_prompt(),
          alive_continuation_prompt: alive_continuation_prompt()
        )

      {:error, :enoen} ->
        IO.puts(:stderr, IEx.color(:eval_error, "No directory #{directory}"))
    end

    IEx.dont_display_result()
  end

  defdelegate d(directory), to: __MODULE__, as: :cd
end

# Ensure only `Helpers.d/1` can be used and not `IEx.Helpers.cd/1`.
import H, only: [cd: 1, d: 1]
import ColorHelpers

IEx.configure(
  inspect: [pretty: true],
  history_size: 500,
  default_prompt: H.default_prompt(),
  continuation_prompt: H.continuation_prompt(),
  alive_prompt: H.alive_prompt(),
  alive_continuation_prompt: H.alive_continuation_prompt()
)

# Print app versions if available.
[
  H.mix_app_version(:default_color, false),
  H.app_version(:phoenix, :light_red, false),
  H.app_version(:ecto, :light_green, false),
  H.app_version(:postgrex, :light_cyan, false),
  H.app_version(:myxql, :light_cyan, false),
  H.app_version(:tds, :light_cyan, false),
  H.app_version(:ecto_sqlite3, :light_cyan, false),
  H.app_version(:ecto_ch, :light_cyan, false),
  H.app_version(:etso, :light_cyan, false),
  H.app_version(:redix, :light_cyan, false)
]
|> Enum.reject(&is_nil/1)
|> Enum.join(format(", ", :light_black))
|> then(
  &if String.length(&1) > 0 do
    IO.puts(&1)
  end
)

# Test list.
dwarves = [
  "Thorin",
  "Fili",
  "Kili",
  "Oin",
  "Gloin",
  "Balin",
  "Dwalin",
  "Ori",
  "Dori",
  "Nori",
  "Bifur",
  "Bofur",
  "Bombur"
]

# Test map.
fellowship = %{
  hobbits: ["Frodo", "Sam", "Merry", "Pippin"],
  humans: ["Aragorn", "Boromir"],
  dwarves: ["Gimli"],
  elves: ["Legolas"],
  wizards: ["Gandolf"]
}
