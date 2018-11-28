defmodule ExTeal.Resource.Update do
  import Plug.Conn

  alias Ecto.Multi
  alias ExTeal.Resource.{Attributes, Update}
  alias Plug.Conn

  @moduledoc """
  Defines a behaviour for updating a resource and the function to execute it.

  It relies on (and uses):

    * ExTeal.Resource.Record
    * ExTeal.Resource.Attributes

  When used ExTeal.Resource.Update defines the `update/2` action suitable for
  handling json-api requests.

  To customize the behaviour of the update action the following callbacks can
  be implemented:

    * ExTeal.Resource.Record.record/2
    * ExTeal.Resource.Records.records/1
    * handle_update/3
    * handle_invalid_update/2
    * render_update/2
    * ExTeal.Resource.Attributes.permitted_attributes/3

  """

  @doc """
  Returns an unpersisted changeset or persisted model representing the newly updated model.

  Receives the conn, the model as found by `record/2`, and the attributes
  argument from the `permitted_attributes` function.

  Default implementation returns the results of calling
  `Model.changeset(model, attrs)`.

  `handle_update/3` can return an %Ecto.Changeset, an Ecto.Schema struct,
  a list of errors (`{:error, [email: "is not valid"]}` or a conn with
  any response/body.

  Example custom implementation:

      def handle_update(conn, post, attributes) do
        current_user_id = conn.assigns[:current_user].id
        case post.author_id do
          ^current_user_id -> {:error, author_id: "you can only edit your own posts"}
          _                -> Post.changeset(post, attributes, :update)
        end
      end

  """
  @callback handle_update(Plug.Conn.t(), ExTeal.Resource.record(), ExTeal.Resource.attributes()) ::
              Plug.Conn.t() | ExTeal.Resource.record() | nil

  @doc """
  Returns a `Plug.Conn` in response to errors during update.

  Default implementation sets the status to `:unprocessable_entity` and renders
  the error messages provided.
  """
  @callback handle_invalid_update(Plug.Conn.t(), Ecto.Changeset.t()) :: Plug.Conn.t()

  @doc """
  Returns a `Plug.Conn` in response to successful update.

  Default implementation renders the view.
  """
  @callback render_update(Plug.Conn.t(), ExTeal.Resource.record()) :: Plug.Conn.t()

  defmacro __using__(_) do
    quote do
      @behaviour ExTeal.Resource.Update
      use ExTeal.Resource.Record
      use ExTeal.Resource.Attributes

      alias ExTeal.Resource.Serializer
      alias Plug.Conn

      def handle_update(conn, nil, _params), do: nil

      def handle_update(_conn, model, attributes) do
        __MODULE__.model().changeset(model, attributes)
      end

      def handle_invalid_update(conn, errors) do
        conn
        |> Conn.put_status(:unprocessable_entity)
        |> Serializer.render_errors(errors)
      end

      def render_update(conn, model) do
        model = repo().preload(model, with())
        Serializer.render_update(model, __MODULE__, conn)
      end

      defoverridable handle_update: 3, handle_invalid_update: 2, render_update: 2
    end
  end

  @doc """
  Execute the update action on a given module implementing Update behaviour and conn.
  """
  def call(resource, resource_id, conn) do
    model = resource.record(conn, resource_id)
    merged = Attributes.from_params(conn.params)
    attributes = resource.permitted_attributes(conn, merged, :update)

    conn
    |> resource.handle_update(model, attributes)
    |> Update.update(resource)
    |> Update.respond(conn, resource)
  end

  def batch_update(resource, conn) do
    new_multi = Multi.new()

    multi =
      Enum.reduce(conn.params["data"], new_multi, fn %{"id" => id, "attributes" => attrs},
                                                     multi ->
        model = resource.record(conn, id)
        cs = resource.handle_update(conn, model, attrs)

        Multi.update(multi, String.to_atom("update_#{id}"), cs)
      end)

    multi
    |> Update.update(resource)
    |> case do
      {:ok, _multi_resp} ->
        send_resp(conn, :accepted, "")

      resp ->
        Update.respond(resp, conn, resource)
    end
  end

  @doc false
  def update(%Ecto.Changeset{} = changeset, resource) do
    resource.repo().update(changeset)
  end

  if Code.ensure_loaded?(Ecto.Multi) do
    def update(%Ecto.Multi{} = multi, resource) do
      resource.repo().transaction(multi)
    end
  end

  def update(other, _resource), do: other

  @doc false
  def respond(%Conn{} = conn, _oldconn, _), do: conn
  def respond(nil, conn, _), do: send_resp(conn, :not_found, "")
  def respond({:error, errors}, conn, resource), do: resource.handle_invalid_update(conn, errors)

  def respond({:error, _name, errors, _changes}, conn, resource),
    do: resource.handle_invalid_update(conn, errors)

  def respond({:ok, model}, conn, resource), do: resource.render_update(conn, model)
  def respond(model, conn, resource), do: resource.render_update(conn, model)
end
