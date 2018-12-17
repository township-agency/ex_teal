defmodule ExTeal.Resource.Delete do
  @moduledoc """
  Defines a behaviour for deleting a resource and the function to execute it.

  It relies on (and uses):

    * ExTeal.Repo
    * ExTeal.Record

  When used ExTeal.Resource.Delete defines the `delete/2` action suitable for
  handling teal delete requests.

  To customize the behaviour of the update action the following callbacks can
  be implemented:

    * handle_delete/2
    * ExTeal.Record.record/2
    * ExTeal.Repo.repo/0
  """
  import Ecto.Query, only: [where: 3]
  import Plug.Conn

  alias ExTeal.Resource.{Delete, Index, Serializer}
  alias Plug.Conn

  @doc """
  Returns an unpersisted changeset or persisted model representing the newly updated model.

  Receives the conn and the record as found by `record/2`.

  Default implementation returns the results of calling `Repo.delete(record)`.

  Example custom implementation:

      def handle_delete(conn, record) do
        case conn.assigns[:user] do
          %{is_admin: true} -> super(conn, record)
          _                 -> send_resp(conn, 401, "nope")
        end
      end

  """
  @callback handle_delete(Ecto.Query.t(), Conn.t()) :: {integer(), nil | [term()]}

  defmacro __using__(_) do
    quote do
      use ExTeal.Resource.Repo
      use ExTeal.Resource.Record
      @behaviour ExTeal.Resource.Delete

      def handle_delete(query, _conn) do
        __MODULE__.repo().delete_all(query)
      end

      defoverridable handle_delete: 2
    end
  end

  @doc """
  Execute the delete action on a given module implementing Delete behaviour and conn.
  """
  def call(resource, conn) do
    resource
    |> find_deleteable(conn)
    |> resource.handle_delete(conn)
    |> Delete.respond(conn)
  end

  @doc false
  def respond(nil, conn), do: not_found(conn)
  def respond(%Plug.Conn{} = conn, _old_conn), do: conn
  def respond({0, nil}, conn), do: not_found(conn)
  def respond({int, nil}, conn) when is_integer(int), do: deleted(conn)
  def respond({:ok, _model}, conn), do: deleted(conn)
  def respond({:errors, errors}, conn), do: invalid(conn, errors)
  def respond({:error, errors}, conn), do: invalid(conn, errors)
  def respond(_model, conn), do: deleted(conn)

  defp not_found(conn) do
    conn
    |> send_resp(:not_found, "")
  end

  defp deleted(conn) do
    conn
    |> send_resp(:no_content, "")
  end

  defp invalid(conn, errors) do
    conn
    |> put_status(:unprocessable_entity)
    |> Serializer.render_errors(errors)
  end

  defp find_deleteable(resource, %Conn{params: %{"resources" => "all"}} = conn) do
    resource.model()
    |> Index.filter(conn, resource)
  end

  defp find_deleteable(resource, %Conn{params: %{"resources" => ids}} = conn) do
    ids = ids |> String.split(",") |> Enum.map(&String.to_integer/1)

    resource.model()
    |> Index.filter(conn, resource)
    |> where([r], r.id in ^ids)
  end
end
