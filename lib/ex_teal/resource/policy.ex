defmodule ExTeal.Resource.Policy do
  @moduledoc """
  Defines a behaviour for authorizing use CRUD
  """

  @callback policy() :: module()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Resource.Policy

      def policy, do: ExTeal.OpenEverywherePolicy

      defoverridable(policy: 0)
    end
  end
end
