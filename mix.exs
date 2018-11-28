defmodule ExTeal.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_teal,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package(),
      description: description(),
      name: "ExTeal",
      organization: "motel",
      source_url: "https://gitlab.motel-lab.com/teal/ex_teal"
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
      {:phoenix, "~> 1.4.0"},
      {:ecto_sql, "~> 3.0"},
      {:ex_machina, "~> 2.2", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:hound, "~> 1.0", only: :test},
      {:html_sanitize_ex, "~> 1.3.0-rc3", only: :test},
      {:phoenix_ecto, "~> 4.0", only: :test}
    ]
  end

  defp description do
    "ExTeal is a beautiful administration dashboard written for Phoenix Apps built
by Motel. The primary feature of ExTeal is the ability to administrate
your data using Ecto Schema and queries. ExTeal acomplishes this by allowing you
to define a ExTeal \"resource\" that corresponds to each Ecto schema in your
application."
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      maintainers: [
        "Alexandrea Defreitas",
        "Caleb Oller",
        "Lydia Koller",
        "Samina Khan",
        "Scott Taylor"
      ],
      licenses: ["MIT"],
      links: %{"GitLab" => "https://gitlab.motel-lab.com/teal/ex_teal"}
    ]
  end

  defp aliases do
    [
      integration: [
        "assets.compile --quiet",
        # "ecto.create -r TestExTeal.Repo --quiet",
        # "ecto.migrate -r TestExTeal.Repo",
        "features"
      ],
      features: "test --only feature:true",
      "assets.compile": &compile_assets/1
    ]
  end

  defp compile_assets(_) do
    Mix.shell().cmd("cd assets && ./node_modules/.bin/vue-cli-service build")
  end
end
