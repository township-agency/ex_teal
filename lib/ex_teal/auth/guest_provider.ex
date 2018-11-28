defmodule ExTeal.Auth.GuestProvider do
  @moduledoc """
  Generic Provider that allows anyone to interact with
  ExTeal.
  """

  use ExTeal.AuthProvider

  alias ExTeal.Auth.Guest
  alias Plug.Conn

  def current_user_for(%Conn{} = _conn) do
    {:ok, %Guest{}}
  end
end
