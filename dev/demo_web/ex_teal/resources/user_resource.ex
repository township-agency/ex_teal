defmodule DemoWeb.ExTeal.UserResource do
  use ExTeal.Resource

  alias Demo.Accounts.User
  alias ExTeal.Fields.{Text}

  def model, do: User

  def fields,
    do: [
      Text.make(:email),
      Text.make(:name)
    ]
end
