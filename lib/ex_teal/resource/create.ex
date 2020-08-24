defmodule ExTeal.Resource.Create do
  @moduledoc """
  Defines a behaviour for creating a resource and the function to execute it.

  It relies on (and uses):

    * ExTeal.Resource.Repo
    * ExTeal.Resource.Model
    * ExTeal.Resource.Attributes

  When used ExTeal.Resource.Create defines the following overrideable callbacks:

    * handle_create/2
    * handle_invalid_create/2
    * render_create/2
    * ExTeal.Resource.Attributes.permitted_attributes/3
    * ExTeal.Resource.Repo.repo/1

  """

  alias ExTeal.Resource.Create

  @doc """
  Returns an unpersisted changeset or persisted model of the newly created object.

  Default implementation returns the results of calling
  `Model.changeset(%Model{}, attrs)` where Model is the model defined by the
  `ExTeal.Resource.Model.model/0` callback.

  The attributes argument is the result of the `permitted_attributes` function.

  `handle_create/2` can return an %Ecto.Changeset, an Ecto.Schema struct,
  a list of errors (`{:error, [email: "is not valid"]}` or a conn with
  any response/body.
  ou
  Example custom implementation:

      def handle_create(_conn, attributes) do
        Post.changeset(%Post{}, attributes, :create_and_publish)
      end

  """
  @callback handle_create(Plug.Conn.t(), ExTeal.Resource.attributes()) ::
              Plug.Conn.t()
              | Ecto.Changeset.t()
              | ExTeal.Resource.record()
              | {:ok, ExTeal.Resource.record()}
              | {:error, ExTeal.Resource.validation_errors()}

  @doc """
  Returns a `Plug.Conn` in response to errors during create.

  Default implementation sets the status to `:unprocessable_entity` and renders
  the error messages provided.
  """
  @callback handle_invalid_create(Plug.Conn.t(), Ecto.Changeset.t()) :: Plug.Conn.t()

  @doc """
  Returns a `Plug.Conn` in response to successful create.

  Default implementation sets the status to `:created` and renders the view.
  """
  @callback render_create(Plug.Conn.t(), ExTeal.Resource.record()) :: Plug.Conn.t()

  defmacro __using__(_) do
    quote do
      @behaviour ExTeal.Resource.Create
      use ExTeal.Resource.Repo
      use ExTeal.Resource.Attributes
      import Plug.Conn

      alias ExTeal.Resource.Serializer

      def handle_create(_conn, attributes) do
        __MODULE__.model().changeset(__MODULE__.model().__struct__, attributes)
      end

      def handle_invalid_create(conn, errors) do
        conn
        |> put_status(:unprocessable_entity)
        |> Serializer.render_errors(errors)
      end

      def render_create(conn, model) do
        conn = put_status(conn, :created)
        Serializer.render_create(model, __MODULE__, conn)
      end

      defoverridable handle_create: 2, handle_invalid_create: 2, render_create: 2
    end
  end

  @doc """
  Creates a resource given a module using Create and a connection.

      Create.call(ArticleResource, conn)
  """
  def call(resource, conn) do
    attributes = resource.permitted_attributes(conn, conn.params, :create)

    conn
    |> resource.handle_create(attributes)
    |> Create.insert(resource)
    |> Create.respond(conn, resource)
  end

  @doc false
  def insert(%Ecto.Changeset{} = changeset, resource) do
    resource.repo().insert(changeset)
  end

  if Code.ensure_loaded?(Ecto.Multi) do
    def insert(%Ecto.Multi{} = multi, resource) do
      resource.repo().transaction(multi)
    end
  end

  def insert(other, _controller), do: other

  @doc false
  def respond(%Plug.Conn{} = conn, _old_conn, _), do: conn

  def respond({:error, errors}, conn, resource),
    do: resource.handle_invalid_create(conn, errors)

  def respond({:error, _name, errors, _changes}, conn, resource),
    do: resource.handle_invalid_create(conn, errors)

  def respond({:ok, model}, conn, resource) do
    model = resource.repo().preload(model, resource.with())
    resource.render_create(conn, model)
  end

  def respond(model, conn, resource), do: resource.render_create(conn, model)
end
