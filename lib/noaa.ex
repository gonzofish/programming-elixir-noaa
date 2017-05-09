defmodule Noaa do
  @moduledoc """
  Documentation for Noaa.
  """
  require Logger
  require Record

  # Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  # Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def test do
    HTTPoison.get("http://w1.weather.gov/xml/current_obs/KDTO.xml")
      |> handle_response
      |> parse_data
  end

  def handle_response({ :ok, %{ status_code: 200, body: body }}) do
    body |> :binary.bin_to_list
      |> :xmerl_scan.string
  end
  def handle_response({ _, %{ status_code: _status_code, body: error }}) do
    Logger.error error
  end

  def parse_data({ xml, _ }) do
    :xmerl_xpath.string('/current_observation/location', xml)
  end
end
