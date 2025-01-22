# ExTeal
Teal is an open-source admin dashboard built in Elixir and Phoenix.

## Installation

Add ExTeal as a dependency in your `mix.exs` file:

```elixir
def deps do
  [
    {:ex_teal, "~> 0.25"}
  ]
end
```

and configure Teal in `config/config.exs`:

```
# config/config.exs

config :ex_teal,
  repo: YourApp.Repo,
  manifest: YourAppWeb.ExTeal.Manifest
```

Teal scales as your business logic scales so we recommend adding a `ex_teal`
directory in the web directory of your phoenix app to store teal resources,
cards, dashboards and other files.  Start your app with an empty manifest:


```elixir
defmodule YourAppWeb.ExTeal.Manifest do
  use ExTeal.Manifest
  alias YourAppWeb.Endpoint

  def application_name, do: "Your cool app name"

  def logo_image_path, do: "#{Endpoint.url()}/images/favicon.png"

  def resources, do: []

  def plugins, do: []

  # defaults to /teal
  def path, do: "/admin"
end
```

and use your router to expose Teal to the web (guarding with appropriate
pipelines for authentication and authorization.

```elixir
  # lib/your_app_web/router.ex
  scope path: "/admin" do
    pipe_through [:browser, :authenticated]
    forward("/", ExTeal.Router, namespace: "admin")
  end
```

Visit `/admin` as an authenticated user and see all the cool :rocket:

## Developing Teal

Update a project that uses Teal to point to your local repo:

```elixir


  defp deps do
    [
      {:ex_teal, path: "../ex_teal"}
    ]
```

In the same project's `dev` config, configure Teal to use `vue-cli` generated
assets rather than the compiled assets.

```elixir
config :ex_teal, compiled_assets: false
```


In your local teal `assets/` folder, host the assets by running `yarn && yarn dev`
