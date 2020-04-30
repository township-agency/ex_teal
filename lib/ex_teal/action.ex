defmodule ExTeal.Action do
  @moduledoc """
  ExTeal Actions allow you to perform one off tasks on your ExTeal Index resources with custom conditions.
  For example you might want to batch update a group of articles to a published state.

  Each ExTeal action should contain a `commit/3` function.

  **Fields have not been implemented yet**

  The commit function is responsible for modifying the state of the application to achieve the desired actions.
  Let's look at the `PublishAction` action:

  ```
  defmodule PortfolioWeb.ExTeal.PublishAction do
    use ExTeal.Action
    alias ExTeal.ActionResponse

    def title, do: "Publish" // defaults to Publish Action
    def key, do: "publish" // default to publish-action

    def commit(conn, fields, query) do
      resources = Repo.all(query) //having the raw query gives you the option to batch large requests.

      with {:ok, _results} <- Portfolio.Content.publish(resources) do //ideally the updates here are part of a Repo.transaction.
        ActionResponse.success("Successfully published")
       _ ->
        ActionResponse.error("Error publishing")
      end
    end
  end
  ```

  The commit should return an ActionResponse struct. The ActionResponse types that are available are 'success', 'error', 'redirect', 'download' and 'push'.
  """

  alias ExTeal.Resource.Index
  alias Plug.Conn

  import Ecto.Query, only: [where: 3]

  @type action_responses :: :ok | {:error, String.t()} | ExTeal.ActionResponse.t()

  @callback options(Plug.Conn.t()) :: list()

  @callback commit(Plug.Conn.t(), [ExTeal.Field.t()], Ecto.Query.t()) :: action_responses()

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
         {:ok, query} <- actionable_query(resource, conn) do
      fields = Map.get(params, "fields", %{})

      {:ok, action.commit(conn, fields, query)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def actionable_query(resource, %Conn{params: %{"resources" => "all"} = params} = conn) do
    query =
      conn
      |> resource.handle_index(params)
      |> Index.field_filters(conn.params, resource)

    case query do
      [] -> {:error, :not_found}
      query -> {:ok, query}
    end
  end

  def actionable_query(resource, %Conn{params: %{"resources" => ids} = params} = conn) do
    ids = ids |> String.split(",") |> Enum.map(&String.to_integer/1)

    query =
      conn
      |> resource.handle_index(params)
      |> Index.field_filters(conn.params, resource)
      |> where([r], r.id in ^ids)

    {:ok, query}
  end

  def message(message), do: %{message: message}

  def error(message), do: %{error: message}
end
