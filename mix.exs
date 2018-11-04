defmodule CizenCells.MixProject do
  use Mix.Project

  def project do
    [
      app: :cizen_cells,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cizen, "~> 0.12.0"},
      {:matrix, "~> 0.3.2"},
      {:poison, "~> 3.1"},
      {:socket, "~> 0.3"}
    ]
  end
end
