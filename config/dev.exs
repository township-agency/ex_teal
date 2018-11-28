use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :ex_teal,
  index_path: "priv/static/teal/index.html"
