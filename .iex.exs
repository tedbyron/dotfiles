# import_file_if_available("~/.iex.exs")

# :observer.start/0
# runtime_info/0 runtime_info/1
# IEx.configure/1 Inspect.Opts

defmodule ColorHelpers do
  @ansi Application.compile_env(:elixir, :ansi_enabled, true)

  @spec ansi_enabled?() :: boolean()
  def ansi_enabled?, do: @ansi

  @spec format(String.t(), atom()) :: String.t()
  def format(string, color) do
    if @ansi do
      IO.ANSI.format([color, string]) |> IO.chardata_to_string()
    else
      string
    end
  end

  @spec puts(String.t(), atom()) :: atom()
  def puts(string, color \\ :default_color) do
    IO.puts(format(string, color))
    IEx.dont_display_result()
  end
end

defmodule H do
  import ColorHelpers

  @ansi ansi_enabled?()
  @home System.user_home!() |> Path.expand()
  @path_separator if elem(:os.type(), 0) == :unix, do: "/", else: "\\"

  # Format the current working directory like fish shell.
  @spec cwd() :: String.t()
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

  @spec cwd_color() :: String.t()
  defp cwd_color, do: format(cwd(), :cyan)

  # Color the node name and host yellow.
  @spec node_color() :: String.t()
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
  @bullet_color format(@bullet, :light_black)

  @doc "Build a prompt from the type passed."
  @spec prompt(atom()) :: String.t()
  @spec prompt(atom(), boolean()) :: String.t()
  def prompt(type, ansi \\ @ansi) do
    case type do
      :default ->
        if ansi, do: "#{cwd_color()} #{@caret_color}", else: "#{cwd()} #{@caret}"

      :alive ->
        if ansi do
          "[#{node_color()}] #{cwd_color()} #{@caret_color}"
        else
          "[#{node()}] #{cwd()} #{@caret}"
        end

      continuation ->
        case continuation do
          :continuation -> prompt(:default, false)
          :alive_continuation -> prompt(:alive, false)
        end
        |> String.length()
        |> then(&String.duplicate(" ", &1 - 1))
        |> then(&if @ansi, do: @bullet_color <> &1, else: @bullet <> &1)
    end
  end

  @spec format_app_version(any(), atom(), charlist(), boolean()) :: String.t()
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

  @doc "If `app` is running, returns its name and version."
  @spec app_version(atom()) :: String.t() | atom()
  @spec app_version(atom(), atom()) :: String.t() | atom()
  @spec app_version(atom(), atom(), boolean()) :: String.t() | atom()
  def app_version(app, color \\ :default_color, puts \\ true) do
    with {_, _, vsn} <- Enum.find(@apps, &(elem(&1, 0) == app)) do
      format_app_version(app, color, vsn, puts)
    end
  end

  @doc "If inside a mix app, puts its name and version."
  @spec mix_app_version() :: String.t() | atom()
  @spec mix_app_version(atom()) :: String.t() | atom()
  @spec mix_app_version(atom(), boolean()) :: String.t() | atom()
  def mix_app_version(color \\ :default_color, puts \\ true) do
    if function_exported?(Mix.Project, :config, 0) do
      config = Mix.Project.config()

      with app when not is_nil(app) <- Keyword.get(config, :app),
           vsn when not is_nil(vsn) <- Keyword.get(config, :version) do
        format_app_version(app, color, vsn, puts)
      end
    end
  end

  @doc """
  Extension of `IEx.Helpers.cd/1` to support `to_string/1` types and the `-` param. Updates the
  `PWD` and `OLDPWD` environment variables, and IEx prompts.
  """
  @spec cd(any()) :: atom()
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

  @spec d(any()) :: atom()
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
