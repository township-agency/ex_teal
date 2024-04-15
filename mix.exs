defmodule ExTeal.MixProject do
  use Mix.Project

  @source "https://github.com/township-agency/ex_teal"

  def project do
    [
      app: :ex_teal,
      version: "0.27.7",
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
      {:phoenix, "~> 1.7"},
      {:phoenix_html, ">= 3.3.0"},
      {:phoenix_ecto, "~> 4.4", only: :test},
      {:phoenix_live_view, "~> 0.20 or ~> 1.0"},
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.10"},
      {:ex_machina, "~> 2.2", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:hound, "~> 1.0", only: :test},
      {:html_sanitize_ex, "~> 1.4.3"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:floki, ">= 0.30.0", only: :test},
      {:nimble_csv, "~> 1.0"},
      {:timex, ">= 3.7.0"},
      {:tzdata, "~> 1.1"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1}
    ]
  end

  defp aliases do
    [
      integration: [
        "assets.compile --quiet",
        "features"
      ],
      features: "test --only feature:true",
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.watch": ["tailwind watch", "esbuild watch"],
      "test.dev": [
        "format --check-formatted",
        "compile --warnings-as-errors --force",
        "credo --strict"
      ]
    ]
  end

  defp description do
    "ExTeal is a beautiful administration dashboard written for Phoenix Apps built
by Township."
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG* priv version*),
      maintainers: [
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
        "guides/Fields.md",
        "guides/Policies.md",
        "README.md",
        "CHANGELOG.md"
      ],
      source_url: @source
    ]
  end
end
