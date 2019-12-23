defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util.ShortCodeMap, as: ShortCodeMapUtil
  alias UAInspector.Util.YAML

  @behaviour UAInspector.ShortCodeMap

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def source do
    {"short_codes.device_brands.yml",
     Config.database_url(:short_code_map, "Parser/Device/DeviceParserAbstract.php")}
  end

  def to_ets([{short, long}]), do: {short, long}
  def var_name, do: "deviceBrands"
  def var_type, do: :hash

  @doc """
  Returns the long representation for a device brand short code.
  """
  @spec to_long(String.t()) :: String.t()
  def to_long(short), do: ShortCodeMapUtil.to_long(list(), short)

  @doc """
  Returns the short code for a device brand.
  """
  @spec to_short(String.t()) :: String.t()
  def to_short(long), do: ShortCodeMapUtil.to_short(list(), long)

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
