defmodule ExTeal.MixProject do
  use Mix.Project

  @source "https://github.com/township-agency/ex_teal"

  def project do
    [
      app: :ex_teal,
      version: File.read!("version.txt") |> String.trim(),
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description(),
      name: "ExTeal",
      source_url: @source,
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ecto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.7"},
      {:corsica, "~> 1.0"},
      {:postgrex, ">= 0.15.0"},
      {:jason, "~> 1.1"},
      {:inflex, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix, "~> 1.4"},
      {:phoenix_html, ">= 2.11.0"},
      {:ecto, "~> 3.5"},
      {:ecto_sql, "~> 3.3"},
      {:ex_machina, "~> 2.2", only: :test},
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:hound, "~> 1.0", only: :test},
      {:html_sanitize_ex, "~> 1.4.1"},
      {:phoenix_ecto, "~> 4.1", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:nimble_csv, "~> 0.7"},
      {:timex, ">= 3.6.0"},
      {:tzdata, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      integration: [
        "assets.compile --quiet",
        "features"
      ],
      features: "test --only feature:true",
      "assets.compile": &compile_assets/1
    ]
  end

  defp compile_assets(_) do
    Mix.shell().cmd("cd assets && ./node_modules/.bin/vue-cli-service build")
  end

  defp description do
    "ExTeal is a beautiful administration dashboard written for Phoenix Apps built
by Motel."
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG* priv version*),
      maintainers: [
        "Alexandrea Defreitas",
        "Caleb Oller",
        "Lydia Koller",
        "Samina Khan",
        "Scott Taylor"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => @source},
      organization: "motel"
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      source_url: @source
    ]
  end
end
