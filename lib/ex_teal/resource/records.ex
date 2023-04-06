defmodule ExTeal.Resource.Records do
  @moduledoc """
  Provides the `records/1` callback used for querying records to be served.

  This is typically the base query that you expose, often scoped to the
  current user.

  This behaviour is used by the following ExTeal.Resource actions:

    * ExTeal.Resource.Index
    * ExTeal.Resource.Show
    * ExTeal.Resource.Update
    * ExTeal.Resource.Delete

  It relies on (and uses):

    * ExTeal.Resource.Model

  """

  import Ecto.Query, only: [from: 2]

  @doc """
  Used to get the base query of records.

  Many/most resources will override this:

      def records(%Plug.Conn{assigns: %{user_id: user_id}}) do
        model()
        |> where([p], p.author_id == ^user_id)
      end

  Return value should be %Plug.Conn{} or an %Ecto.Query{}.
  """
  @callback records(Plug.Conn.t(), module()) :: Plug.Conn.t() | Ecto.Query.t()

  @doc """
  Used to specify which relationships to always
  preload with all requests.
  """
  @callback with() :: [atom()]

  defmacro __using__(_) do
    quote do
      unless ExTeal.Resource.Records in @behaviour do
        use ExTeal.Resource.Model
        alias ExTeal.Resource.Records
        @behaviour ExTeal.Resource.Records

        def records(_conn, module) do
          model()
        end

        def with, do: []

        defoverridable records: 2, with: 0
      end
    end
  end

  def preload(model, module) do
    preloads = module.with()
    from(q in model, preload: ^preloads)
  end
end
