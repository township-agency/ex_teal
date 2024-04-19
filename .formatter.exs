# Used by "mix format"
[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["{mix,.formatter,dev}.exs", "{config,lib,test,dev}/**/*.{heex,ex,exs}"]
]
