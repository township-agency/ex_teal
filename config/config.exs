# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :ex_teal,
  export_module: NimbleCSV.RFC4180

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_encoder, Jason

import_config "#{Mix.env()}.exs"
