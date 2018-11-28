defmodule ExTeal.Manifest do
  @moduledoc """
  Behavior for configuring and defining ExTeal
  """
  defmacro __using__(_opts) do
    quote do
      use ExTeal.Application.Configuration
    end
  end
end
