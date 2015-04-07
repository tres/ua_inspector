defmodule Mix.Tasks.UAInspector.Verify.Fixtures do
  @moduledoc """
  Utility module to bundle/download verification fixtures.
  """

  @fixture_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/Tests/fixtures"

  @fixtures [
    "camera.yml",
    "car_browser.yml",
    "console.yml",
    "desktop.yml",
    "feature_phone.yml",
    "feed_reader.yml",
    "mediaplayer.yml",
    "mobile_apps.yml",
    "phablet.yml",
    "portable_media_player.yml",
    "smart_display.yml",
    "smartphone.yml",
    "tablet.yml",
    "tv.yml",
    "unknown.yml"
  ]

  def download() do
    Mix.shell.info "Download path: #{ download_path }"

    setup()
    download(@fixtures)

    Mix.shell.info "Download complete!"
    :ok
  end

  def download([]),                    do: :ok
  def download([ fixture | fixtures ]) do
    Mix.shell.info ".. downloading: #{ fixture }"
    File.write!(
      download_path(fixture),
      Mix.Utils.read_path!("#{ @fixture_base_url }/#{ fixture }")
    )

    download(fixtures)
  end

  def download_path,       do: Path.join(__DIR__, "../../../../../fixtures") |> Path.expand()
  def download_path(file), do: Path.join(download_path, file)
  def list,                do: @fixtures

  def setup() do
    File.rm_rf! download_path
    File.mkdir_p! download_path
  end
end
