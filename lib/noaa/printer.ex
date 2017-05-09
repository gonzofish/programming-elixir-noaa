defmodule Noaa.Printer do
  @default_attributes [
    { "Last Updated", "observation_time_rfc822" },
    { "Weather", "weather" },
    { "Temperature", "temperature_string" },
    { "Dewpoint", "dewpoint_string" },
    { "Relative Humidity (%)", "relative_humidity" },
    { "Wind", "wind_string" },
    { "Visibility (mi.)", "visibility_mi" },
    { "Altimeter (in. Hg)", "pressure_in" }
  ]

  def print(elements, attributes \\ @default_attributes) do
    element_map = _create_element_map(elements)

    _get_header(element_map)
    _print_attributes(element_map, attributes)
  end

  defp _create_element_map(elements) do
    Enum.reduce(elements, %{}, fn(element, element_map) ->
      Map.put(element_map, element.tag_name, element)
    end)
  end

  defp _get_header(elements) do
    IO.puts ""
    IO.puts " #{ elements.location.text }"
    IO.puts " elements.station_id.text }"
    IO.puts " #{ elements.latitude.text }, #{ elements.longitude.text }"
    IO.puts ""
  end

  defp _print_attributes(elements, attributes) do
    padding = (Enum.map(attributes, fn({ label, _ }) -> String.length(label) end)
      |> Enum.max) + 1
    Enum.each(attributes, fn({ label, field }) ->
      IO.puts String.pad_leading(label, padding) <> " " <>
        elements[String.to_atom(field)].text
    end)
  end
end