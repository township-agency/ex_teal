defmodule ExTeal.Resource.Show do
  @moduledoc """
  Defines a behaviour for displaying a resource and the function to execute it.

  It relies on (and uses):

    * ExTeal.Resource.Record
    * ExTeal.Resource.Serializable

  When used ExTeal.Resource.Show defines the `show/2` action suitable for handling
  api requests.

  To customize the behaviour of the show action the following callbacks can be implemented:

    * handle_show/2
    * render_show/2
    * ExTeal.Resource.Record.record/2
    * ExTeal.Resource.Record.records/1

  """

  alias ExTeal.Resource.Serializer
  alias ExTeal.Resource.Show
  alias Plug.Conn

  @doc """
  Returns the model to be represented by this resource.

  Default implementation is the result of the ExTeal.Resource.Record.record/2
  callback.

  `handle_show/2` can return nil to send a 404, a conn with any response/body,
  or a record to be serialized.

  Example custom implementation:

      def handle_show(conn, id) do
        Repo.get_by(Post, slug: id)
      end

  In most cases ExTeal.Resource.Record.record/2 and ExTeal.Resource.Records.records/1 are
  the better customization hooks.
  """
  @callback handle_show(Plug.Conn.t(), ExTeal.Resource.id()) ::
              Plug.Conn.t() | ExTeal.Resource.record()

  @doc """
  Returns a `Plug.Conn` in response to successful show.

  Default implementation renders the view.
  """
  @callback render_show(ExTeal.Resource.record(), any(), Plug.Conn.t()) :: Plug.Conn.t()

  defmacro __using__(_) do
    quote do
      use ExTeal.Resource.Record
      @behaviour ExTeal.Resource.Show

      alias ExTeal.Resource.Serializer

      def handle_show(conn, id), do: record(conn, id)

      def render_show(model, resource, conn) do
        Serializer.render_show(model, resource, conn)
      end

      defoverridable handle_show: 2, render_show: 3
    end
  end

  @doc """
  Execute the show action on a given module implementing Show behaviour and conn.
  """
  def call(resource, conn, id) do
    conn
    |> resource.handle_show(id)
    |> Show.respond(resource, conn)
  end

  @doc false
  def respond(%Plug.Conn{} = conn, _resource, _old_conn), do: conn

  def respond(nil, _resource, conn) do
    conn
    |> Conn.put_status(:not_found)
    |> Serializer.error(:not_found)
  end

  def respond(model, resource, conn), do: resource.render_show(model, resource, conn)
end
