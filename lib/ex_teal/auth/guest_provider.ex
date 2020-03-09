defmodule ExTeal.Auth.GuestProvider do
  @moduledoc """
  Generic Provider that allows anyone to interact with
  ExTeal.
  """

  use ExTeal.AuthProvider

  alias Plug.Conn

  @impl true
  def current_user_for(%Conn{} = _conn) do
    %{name: nil, avatar_url: nil}
  end
end
