defmodule ExTeal.AuthProvider do
  @moduledoc """
  Interface for providing authorization and authentication to ExTeal.
  """

  @callback current_user_for(Plug.Conn.t()) :: {:ok, struct()} | {:error, atom()}

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.AuthProvider
    end
  end
end
