use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

config :ex_teal, TestExTealWeb.Endpoint,
  http: [port: 4001],
  secret_key_base: "HL0pikQMxNSA58Dv4mf26O/eh1e4vaJDmX0qLgqBcnS94gbKu9Xn3x114D+mHYcX",
  server: true

config :ex_teal, ecto_repos: [TestExTealRepo]

config :ex_teal, TestExTeal.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  database: "teal_test",
  hostname: if(System.get_env("CI"), do: "postgres", else: "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox

config :ex_teal,
  base_url: "http://localhost:4001/teal"

config :hound, driver: "chrome_driver"
