defmodule Noaa do
  @moduledoc """
  Documentation for Noaa.
  """

  def test do
    Noaa.Http.fetch("KNEL")
      |> :binary.bin_to_list
      |> :xmerl_scan.string
      |> (fn ({ xml, _ }) -> xml end).()
      |> Noaa.Parser.parse
      |> Noaa.Printer.print
  end
end
