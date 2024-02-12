# iex_config = Path.expand("~/.iex.exs")
# if iex_config |> File.exists?() do
#   import iex_config
# end

# :observer.start/0
# runtime_info/0 runtime_info/1
# IEx.configure/1 Inspect.Opts

defmodule Color do
  def color(string, color) do
    IO.ANSI.format([color, string])
    |> IO.chardata_to_string()
  end
end

defmodule Helpers do
  import Color

  @home System.user_home!() |> Path.expand()
  @path_separator if elem(:os.type(), 0) == :unix, do: "/", else: "\\"

  # Format the current working directory like fish shell and color it cyan.
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
    |> color(:cyan)
  end

  # Color the node name and host yellow.
  defp node_color do
    node()
    |> to_string()
    |> String.split("@")
    |> Enum.map(&color(&1, :yellow))
    |> Enum.join("@")
  end

  @caret color("\uf0da", :blue)
  @bullet color("\u2219", :light_black)

  def default_prompt, do: cwd() <> " " <> @caret
  def alive_prompt, do: cwd() <> " " <> node_color() <> " " <> @caret
  def continuation_prompt, do: @bullet <> String.duplicate(" ", String.length(default_prompt()))

  def alive_continuation_prompt,
    do: @bullet <> String.duplicate(" ", String.length(alive_prompt()))

  @apps Application.started_applications()

  # If `app` is running, puts its name in `color` and version.
  def puts_app_version(app, color) do
    with {_, _, vsn} <- Enum.find(@apps, &(elem(&1, 0) == app)) do
      to_string(app)
      |> color(color)
      |> then(&IO.puts("#{&1}: #{vsn}"))
    end
  end

  # If inside a mix app, puts its name and version.
  def puts_mix_app_version(color \\ :default_color) do
    if function_exported?(Mix.Project, :config, 0) do
      config = Mix.Project.config()

      with app when not is_nil(app) <- Keyword.get(config, :app),
           vsn when not is_nil(vsn) <- Keyword.get(config, :version) do
        to_string(app)
        |> color(color)
        |> then(&IO.puts("#{&1}: #{vsn}"))
      end
    end

    IEx.dont_display_result()
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

Application.put_env(:elixir, :ansi_enabled, true)

IEx.configure(
  default_prompt: Helpers.default_prompt(),
  continuation_prompt: Helpers.continuation_prompt(),
  alive_prompt: Helpers.alive_prompt(),
  alive_continuation_prompt: Helpers.alive_continuation_prompt(),
  inspect: [pretty: true]
)

Helpers.puts_mix_app_version()
Helpers.puts_app_version(:phoenix, :light_red)
Helpers.puts_app_version(:ecto, :light_green)
Helpers.puts_app_version(:postgrex, :light_cyan)
Helpers.puts_app_version(:myxql, :light_cyan)
Helpers.puts_app_version(:tds, :light_cyan)
Helpers.puts_app_version(:ecto_sqlite3, :light_cyan)
Helpers.puts_app_version(:ecto_ch, :light_cyan)
Helpers.puts_app_version(:etso, :light_cyan)
Helpers.puts_app_version(:redix, :light_cyan)

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

# Ensure only `Helpers.d/1` can be used and not `IEx.Helpers.cd/1`.
import Helpers, only: [cd: 1, d: 1]
