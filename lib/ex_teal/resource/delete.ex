defmodule ExTeal.Resource.Delete do
  import Plug.Conn
  alias ExTeal.Resource.{Delete, Serializer}

  @moduledoc """
  Defines a behaviour for deleting a resource and the function to execute it.

  It relies on (and uses):

    * ExTeal.Repo
    * ExTeal.Record

  When used ExTeal.Resource.Delete defines the `delete/2` action suitable for
  handling json-api requests.

  To customize the behaviour of the update action the following callbacks can
  be implemented:

    * handle_delete/2
    * ExTeal.Record.record/2
    * ExTeal.Repo.repo/0

  """

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
  @callback handle_delete(Plug.Conn.t(), ExTeal.record()) :: Plug.Conn.t() | ExTeal.record() | nil

  defmacro __using__(_) do
    quote do
      use ExTeal.Resource.Repo
      use ExTeal.Resource.Record
      @behaviour ExTeal.Resource.Delete
      def handle_delete(conn, nil), do: nil

      def handle_delete(conn, model) do
        model
        |> __MODULE__.model().changeset(%{})
        |> __MODULE__.repo().delete
      end

      defoverridable handle_delete: 2
    end
  end

  @doc """
  Execute the delete action on a given module implementing Delete behaviour and conn.
  """
  def call(resource, id, conn) do
    model = resource.record(conn, id)

    conn
    |> resource.handle_delete(model)
    |> Delete.respond(conn)
  end

  @doc false
  def respond(nil, conn), do: not_found(conn)
  def respond(%Plug.Conn{} = conn, _old_conn), do: conn
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
end
