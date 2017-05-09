defmodule Noaa.CLI do

  @moduledoc"""
  Handle the command line parsing and dispatch to
  the various functions that end up generating a
  table of NOAA station data
  """

  def main(argv), do: run(argv)
  def run(argv) do
    argv
      |> parse_args
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help

  Othwerise it is a GitHub username, user, and
  (optionally) the number of issues to format

  Return a tuple of `{ user, project, count }`
  or :help if help was given
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv,
      switches: [ help: :boolean ],
      aliases: [ h: :help ]
    )

    case parse do
      { [ help: true ], _ } -> :help
      { _, [ station_id ], _} -> { station_id }
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <station ID>
    """
    System.halt(0)
  end

  def process({ station_id }) do
    Noaa.Http.fetch(station_id)
      |> :binary.bin_to_list
      |> :xmerl_scan.string
      |> (fn ({ xml, _ }) -> xml end).()
      |> Noaa.Parser.parse
      |> Noaa.Printer.print
  end
end
