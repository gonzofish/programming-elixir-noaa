defmodule Noaa.Mixfile do
  use Mix.Project

  def project do
    [app: :noaa,
     escript: escript_config(),
     version: "0.1.0",
     elixir: "~> 1.4",
     name: "NOAA Station Data",
     source_url: "https://github.com/gonzofish/programming-elixir-noaa",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      { :httpoison, "~> 0.9.0" }
    ]
  end

  defp escript_config do
    [ main_module: Noaa.CLI ]
  end
end
