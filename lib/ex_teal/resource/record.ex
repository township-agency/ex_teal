defmodule ExTeal.Resource.Record do
  @moduledoc """
  This behaviour is used by the following ExTeal.Resource actions:

    * ExTeal.Resource.Show
    * ExTeal.Resource.Update
    * ExTeal.Resource.Delete

  It relies on (and uses):

    * ExTeal.Resource.Records

  """

  @doc """
  Used to get the subject of the current action

  Many/most controllers will override this:

      def record(%Plug.Conn{assigns: %{user_id: user_id}}, id) do
        model()
        |> where([p], p.author_id == ^user_id)
        |> Repo.get(id)
      end

  """
  @callback record(Plug.Conn.t(), ExTeal.Resource.id()) ::
              Plug.Conn.t() | ExTeal.Resource.record()

  defmacro __using__(_) do
    quote do
      unless ExTeal.Resource.Record in @behaviour do
        use ExTeal.Resource.Records
        alias ExTeal.Resource.Records
        @behaviour ExTeal.Resource.Record

        def record(conn, id) do
          conn
          |> records(__MODULE__)
          |> Records.preload(__MODULE__)
          |> repo().get(id)
        end

        defoverridable record: 2
      end
    end
  end
end
