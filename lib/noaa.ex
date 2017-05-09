defmodule Noaa do
  @moduledoc """
  Documentation for Noaa.
  """
  require Logger

  def test do
    HTTPoison.get("http://w1.weather.gov/xml/current_obs/KDTO.xml")
      |> handle_response
      |> Noaa.Parser.parse
  end

  def handle_response({ :ok, %{ status_code: 200, body: body }}) do
    {xml, _ } = body |> :binary.bin_to_list
      |> :xmerl_scan.string
    xml
  end
  def handle_response({ _, %{ status_code: _status_code, body: error }}) do
    Logger.error error
  end
end
