# ExTeal

## Installation

Add ExTeal to your packages:

```elixir
def deps do
  [
    {:ex_teal, "~> 0.1"}
  ]
end
```

Stuff here! One Day!

```elixir
defmodule YourAppWeb.ExTeal do
  alias YourAppWeb.Resources

  def resources, do: [
    Resources.User
  ]
end
```

## Developing Teal

Update a project that uses Teal to point to your local repo:

```elixir


  defp deps do
    [
      {:ex_teal, path: "../ex_teal"}
    ]
```

In the same projects, `dev` config, configure Teal to use `vue-cli` generated
assets rather then the compiled assets.

```elixir
config :ex_teal, compiled_assets: false
```

Run `yarn && yarn serve`
