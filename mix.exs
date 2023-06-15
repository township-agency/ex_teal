defmodule ExTeal.MixProject do
  use Mix.Project

  @source "https://github.com/township-agency/ex_teal"

  def project do
    [
      app: :ex_teal,
      version: "0.22.0",
      elixir: "~> 1.12",
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
      {:plug, "~> 1.14"},
      {:corsica, "~> 1.0"},
      {:postgrex, ">= 0.15.0"},
      {:jason, "~> 1.1"},
      {:inflex, "~> 2.0"},
      {:plug_cowboy, "~> 2.5"},
      {:phoenix, "~> 1.5"},
      {:phoenix_html, ">= 2.11.0"},
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.10"},
      {:ex_machina, "~> 2.2", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:hound, "~> 1.0", only: :test},
      {:html_sanitize_ex, "~> 1.4.1"},
      {:phoenix_ecto, "~> 4.1", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:nimble_csv, "~> 1.0"},
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
      "assets.compile": &compile_assets/1,
      "test.dev": [
        "format --check-formatted",
        "compile --warnings-as-errors --force",
        "credo --strict"
      ]
    ]
  end

  defp compile_assets(_) do
    Mix.shell().cmd("cd assets && ./node_modules/.bin/vue-cli-service build")
  end

  defp description do
    "ExTeal is a beautiful administration dashboard written for Phoenix Apps built
by Township."
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG* priv version*),
      maintainers: [
        "Caleb Oller",
        "Lydia Koller",
        "Samina Khan",
        "Scott Taylor"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => @source}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "guides/Policies.md",
        "README.md",
        "CHANGELOG.md"
      ],
      source_url: @source
    ]
  end
end
