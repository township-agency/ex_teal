# Policies

Policies are a way of controlling access to resources within Teal.

## Default policy

The default policy is `ExTeal.OpenEverywherePolicy`, which has the following implementations:

```elixir
# Resource level permissions
def create_any?(_conn), do: true
def view_any?(_conn), do: true
def update_any?(_conn), do: true
def delete_any?(_conn), do: true

# Resource item level permissions
def view?(_conn, _item), do: true
def update?(_conn, _item), do: true
def delete?(_conn, _item), do: true
```

To change the default policy, create a new policy module e.g:

```elixir
# lib/my_app_web/ex_teal/closed_everywhere_policy.ex

defmodule MyAppWeb.ExTeal.ClosedEverywherePolicy do
  use ExTeal.Policy

  def create_any?(_conn), do: false
  def view_any?(_conn), do: false
  def update_any?(_conn), do: false
  def delete_any?(_conn), do: false

  def view?(_conn, _item), do: false
  def update?(_conn, _item), do: false
  def delete?(_conn, _item), do: false
end

```

Then set it in your manifest:

```elixir
# lib/my_app_web/ex_teal/manifest.ex

defmodule MyAppWeb.ExTeal.Manifest do
  use ExTeal.Manifest
  
  # ...

  def default_policy, do: MyAppWeb.ExTeal.ClosedEverywherePolicy
  
  # ...
end

```

## Resource Policies

You can override the policy at the resource level by implementing the `policy/0` callback

```elixir
# lib/my_app_web/ex_teal/resources/thing_resource.ex

defmodule MyAppWeb.ExTeal.ThingResource do
  use ExTeal.Resource
  
  alias ExTeal.Fields.{
    ID,
    Text
  }

  def policy, do: MyAppWeb.ExTeal.ThingPolicy

  # ...

  def fields,
    do: [
      ID.make(:id),
      Text.make(:title),
    ]
end
```

Lets create that resource policy:

```elixir
# lib/my_app_web/ex_teal/thing_policy.ex

defmodule MyAppWeb.ExTeal.ThingPolicy do
  use ExTeal.Policy

  # Only allow the super_admin role to interact with "Thing"s

  def create_any?(conn) do
    conn.assigns.current_user.role == :super_admin
  end

  def view_any?(conn) do
    conn.assigns.current_user.role == :super_admin
  end

  def update_any?(conn) do
    conn.assigns.current_user.role == :super_admin
  end

  def delete_any?(conn) do
    conn.assigns.current_user.role == :super_admin
  end

  def view?(conn, _thing) do
    conn.assigns.current_user.role == :super_admin
  end

  def update?(conn, _thing) do
    conn.assigns.current_user.role == :super_admin
  end

  def delete?(conn, _thing) do
    conn.assigns.current_user.role == :super_admin
  end
end
```