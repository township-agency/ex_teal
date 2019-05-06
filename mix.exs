defmodule ExTeal.MixProject do
  use Mix.Project

  @version "0.1.6"

  @source "https://gitlab.motel-lab.com/teal/ex_teal"

  def project do
    [
      app: :ex_teal,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description(),
      name: "ExTeal",
      source_url: @source
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
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.1"},
      {:inflex, "~> 1.10.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix, "~> 1.4"},
      {:ecto_sql, "~> 3.0"},
      {:ex_machina, "~> 2.2", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:hound, "~> 1.0", only: :test},
      {:html_sanitize_ex, "~> 1.3.0-rc3", only: :test},
      {:phoenix_ecto, "~> 4.0", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
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
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG* priv),
      maintainers: [
        "Alexandrea Defreitas",
        "Caleb Oller",
        "Lydia Koller",
        "Samina Khan",
        "Scott Taylor"
      ],
      licenses: ["MIT"],
      links: %{"GitLab" => @source},
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
      source_ref: "v#{@version}",
      source_url: @source
    ]
  end
end
