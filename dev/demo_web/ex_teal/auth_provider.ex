defmodule DemoWeb.ExTeal.AuthProvider do
  @moduledoc """
  Provides information about the current user for Teal
  """
  use ExTeal.AuthProvider
  alias Phoenix.HTML
  alias Plug.Conn
  alias Demo.Accounts.User

  def current_user_for(%Conn{assigns: %{current_user: %User{} = user}}) do
    %{
      name: user.name,
      avatar_url: nil
    }
  end

  def current_user_for(_), do: nil

  def dropdown_content(_conn), do: []
end
