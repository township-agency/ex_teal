defmodule ExTeal.Policy do
  @moduledoc """
  A Policy authorizes CRUD use of a resource based on the Plug.Conn
  """

  @doc """
  Can a user create a resource?
  Returning false will disable the '+' button on a resource and return a 403 on api requests
  """
  @callback create_any?(Plug.Conn.t()) :: boolean()

  @doc """
  Can the resource be viewed at all?
  Returning false will hide the resource in the sidebar and in relationships
  and return a 403 on api requests
  """
  @callback view_any?(Plug.Conn.t()) :: boolean()

  @doc """
  Can a user update any records?
  Returning false will disable the 'edit' button on a record and return a 403 on api requests
  """
  @callback update_any?(Plug.Conn.t()) :: boolean()

  @doc """
  Can a user delete any resource?
  Returning false will disable the 'delete' buttons on all resource records
  and return a 403 on api requests
  """
  @callback delete_any?(Plug.Conn.t()) :: boolean()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExTeal.Policy

      def create_any?(_), do: true
      def view_any?(_), do: true
      def update_any?(_), do: true
      def delete_any?(_), do: true

      defoverridable(
        create_any?: 1,
        view_any?: 1,
        update_any?: 1,
        delete_any?: 1
      )
    end
  end
end
