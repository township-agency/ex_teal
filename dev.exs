Logger.configure(level: :debug)

pg_url = System.get_env("PG_URL") || "postgres:postgres@127.0.0.1"

Application.put_env(:ex_teal, Demo.Repo, url: "ecto://#{pg_url}/ex_teal_dev")
_ = Ecto.Adapters.Postgres.storage_down(Demo.Repo.config())
_ = Ecto.Adapters.Postgres.storage_up(Demo.Repo.config())

Application.put_env(:esbuild, :version, "0.17.11")

Application.put_env(:esbuild, :dev_build,
  args:
    ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
  cd: Path.expand("../assets", __DIR__),
  env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
)

Application.put_env(:tailwind, :version, "3.4.0")

Application.put_env(:tailwind, :dev_build,
  args: ~w(
  --config=tailwind.config.js
  --input=css/app.css
  --output=../priv/static/assets/app.css
),
  cd: Path.expand("../assets", __DIR__)
)

Application.put_env(:ex_teal, DemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "B0OYotdOFFzmtBQPuRVtmMelQwAZkQkREcv9JkQi7HsmCKW/eNIyAzX6WWMIsP7L",
  live_view: [signing_salt: "F8eNKLsr8FQalABE"],
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  check_origin: false,
  code_reloader: true,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:dev_build, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:dev_build, ~w(--watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/ex_teal/(controllers|live|components)/.*(ex|heex)$",
      ~r"lib/ex_teal/templates/.*/.*(ex)$",
      ~r"lib/ex_teal/.*(ex)$"
    ]
  ],
  pubsub_server: Demo.PubSub
)

Application.put_env(:ex_teal, :repo, Demo.Repo)
Application.put_env(:ex_teal, :manifest, DemoWeb.ExTeal.Manifest)

Application.put_env(:phoenix, :serve_endpoints, true)

Application.ensure_all_started(:os_mon)

Task.async(fn ->
  children = [
    Demo.Repo,
    DemoWeb.Endpoint,
    {Phoenix.PubSub, name: Demo.PubSub, adapter: Phoenix.PubSub.PG2}
  ]

  {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one, name: Demo.Supervisor)

  path = Ecto.Migrator.migrations_path(Demo.Repo, "demo_migrations")
  {:ok, _, _} = Ecto.Migrator.with_repo(Demo.Repo, &Ecto.Migrator.run(&1, path, :up, all: true))

  Demo.Populator.reset()

  Process.sleep(:infinity)
end)
|> Task.await(:infinity)
