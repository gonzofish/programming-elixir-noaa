defmodule Noaa.Http do
  require Logger
  @noaa_url Application.get_env(:noaa, :noaa_url)

  def fetch(code) do

    HTTPoison.get("#{ @noaa_url }/#{ code }.xml")
      |> handle_response
  end

  def handle_response({ :ok, %{ status_code: 200, body: body }}) do
    body
  end
  def handle_response({ _, %{ status_code: _status_code, body: error }}) do
    Logger.error error
  end
end