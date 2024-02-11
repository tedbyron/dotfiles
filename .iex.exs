# home_iex = Path.expand("~/.iex.exs")
# if home_iex |> File.exists?() do
#   import home_iex
# end

# :observer.start()
# runtime_info <:memory|:application|..>
# IEx.configure inspect: [limit: :infinity]

defmodule H do
  alias IO.ANSI

  @home System.user_home() |> Path.expand()
  @path_sep if elem(:os.type(), 0) == :unix, do: "/", else: "\\"
  @caret ANSI.format([:blue, "\uf0da"]) |> IO.chardata_to_string()
  @bullet ANSI.format([:light_black, "\u2219"]) |> IO.chardata_to_string()

  # Format cwd like fish shell.
  @spec cwd() :: iodata()
  defp cwd do
    case [@home, File.cwd()] do
      [home, cwd] when home == nil or elem(cwd, 0) == :error ->
        "nil"

      [home, {:ok, cwd}] ->
        [dir | rest] =
          cwd
          |> Path.expand()
          |> String.replace_prefix(home, "~")
          |> String.split("/")
          |> Enum.reverse()

        [dir | Enum.map(rest, fn s -> String.first(s) || s end)]
        |> Enum.reverse()
        |> Enum.join(@path_sep)
    end
    |> then(&ANSI.format([:cyan, &1]))
    |> IO.chardata_to_string()
  end

  @spec default_prompt() :: iodata()
  def default_prompt do
    cwd() <> " " <> @caret
  end

  @spec continuation_prompt() :: iodata()
  def continuation_prompt do
    @bullet
  end

  @spec alive_prompt() :: iodata()
  def alive_prompt do
    cwd() <> " " <> @caret
  end

  @spec alive_continuation_prompt() :: iodata()
  def alive_continuation_prompt do
    @bullet
  end
end

Application.put_env(:elixir, :ansi_enabled, true)

IEx.configure(
  default_prompt: H.default_prompt(),
  continuation_prompt: H.continuation_prompt(),
  alive_prompt: H.alive_prompt(),
  alive_continuation_prompt: H.alive_continuation_prompt(),
  inspect: [pretty: true]
)
