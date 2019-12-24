defmodule UAInspector.Database.OSs do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util
  alias UAInspector.Util.YAML

  @behaviour UAInspector.Database

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def sources do
    [{"", "os.oss.yml", Config.database_url(:os, "oss.yml")}]
  end

  def to_ets(data, _type) do
    data = Enum.into(data, %{})

    {
      Util.build_regex(data["regex"]),
      {
        data["name"] || "",
        to_string(data["version"] || "")
      }
    }
  end

  defp parse_yaml_entries({:ok, entries}, type, _) do
    Enum.map(entries, &to_ets(&1, type))
  end

  defp parse_yaml_entries({:error, error}, _, database) do
    _ =
      unless Config.get(:startup_silent) do
        Logger.info("Failed to load database #{database}: #{inspect(error)}")
      end

    []
  end

  defp read_database do
    sources()
    |> Enum.reverse()
    |> Enum.reduce([], fn {type, local, _remote}, acc ->
      database = Path.join([Config.database_path(), local])

      contents =
        database
        |> YAML.read_file()
        |> parse_yaml_entries(type, database)

      [contents | acc]
    end)
    |> List.flatten()
  end
end
