defmodule UAInspector.ShortCodeMap.OSFamilies do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util.YAML

  @behaviour UAInspector.ShortCodeMap

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def source do
    {"short_codes.os_families.yml",
     Config.database_url(:short_code_map, "Parser/OperatingSystem.php")}
  end

  def to_ets([{family, codes}]), do: {family, codes}
  def var_name, do: "osFamilies"
  def var_type, do: :hash_with_list

  defp read_database do
    {local, _} = source()
    map = Path.join(Config.database_path(), local)

    map
    |> YAML.read_file()
    |> parse_yaml_entries(map)
  end

  defp parse_yaml_entries({:ok, entries}, _) do
    Enum.map(entries, &to_ets/1)
  end

  defp parse_yaml_entries({:error, error}, map) do
    _ =
      unless Config.get(:startup_silent) do
        Logger.info("Failed to load short code map #{map}: #{inspect(error)}")
      end

    []
  end
end
