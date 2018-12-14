defmodule ExTeal.Action do
  @moduledoc """
  ExTeal Actions allow you to scope your ExTeal Index queries with custom conditions. For example, you may
  wish to define a filter to quickly view "Published" posts within your application:

  Each ExTeal filter should contain two functions: `apply/3` and `options/1`.
  The apply function is responsible for modifying the query to achieve the desired filter state, while
  the options function determines the "values" the filter may have.  Let's look at the
  `PublishedStatus` filter:

  ```
  defmodule PortfolioWeb.ExTeal.PublishAction do
    use ExTeal.Filter

    import Ecto.Query, only: [from: 2]

    def title, do: "Publish"
    def key, do: "publish"

    def commit(conn, fields, resources) do
      for post <- resources do
        Portfolio.Content.publish(post)
      end
      :ok
    end
  end
  ```

  The commit should return an `:ok` or an `{:error, "error message"}` tuple.  You should not write the example above,
  but wrap the database updates in at least a transaction inside your main context.

  Notice that because the params for the filter are encoded as query params they should be url safe and handled as url params.
  """

  alias ExTeal.Resource.Index
  alias Plug.Conn

  import Ecto.Query, only: [where: 3]

  @callback options(Conn.t()) :: list()

  defmacro __using__(_) do
    quote do
      @behaviour ExTeal.Action
      alias ExTeal.Action

      @implied_title Phoenix.Naming.resource_name(__MODULE__)
      @implied_key Phoenix.Naming.underscore(@implied_title)

      def title, do: @implied_title
      def key, do: @implied_key

      def build_for(conn), do: Action.build_for(__MODULE__, conn)

      def options(_conn),
        do: %{
          available_for_entire_resource: true
        }

      defoverridable options: 1, title: 0, key: 0
    end
  end

  def build_for(action_module, conn) do
    %{
      key: action_module.key(),
      title: action_module.title(),
      options: action_module.options(conn),
      destructive: false,
      fields: []
    }
  end

  def action_for_key(actions, key) do
    case Enum.find(actions, &(key == &1.key())) do
      nil -> {:error, :not_found}
      action -> {:ok, action}
    end
  end

  def apply_action(resource, %Conn{params: params} = conn) do
    with {:ok, action} <- action_for_key(resource.actions(conn), params["action"]),
         {:ok, schemas} <- find_actionable(resource, conn) do
      fields = Map.get(params, "fields", %{})

      {:ok, action.commit(conn, fields, schemas)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def find_actionable(resource, %Conn{params: %{"resources" => "all"}} = conn) do
    results =
      resource.model()
      |> Index.filter(conn, resource)
      |> resource.repo().all()

    case results do
      [] -> {:error, :not_found}
      results -> {:ok, results}
    end
  end

  def find_actionable(resource, %Conn{params: %{"resources" => ids}} = conn) do
    ids = ids |> String.split(",") |> Enum.map(&String.to_integer/1)

    results =
      resource.model()
      |> Index.filter(conn, resource)
      |> where([r], r.id in ^ids)
      |> resource.repo().all()

    case results do
      [] -> {:error, :not_found}
      results -> {:ok, results}
    end
  end

  def message(message), do: %{message: message}

  def error(message), do: %{error: message}
end
