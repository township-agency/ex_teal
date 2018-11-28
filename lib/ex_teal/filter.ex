defmodule ExTeal.Filter do
  @moduledoc """

  ExTeal Filters allow you to scope your ExTeal Index queries with custom conditions. For example, you may
  wish to define a filter to quickly view "Published" posts within your application:

  Each ExTeal filter should contain two functions: `apply/3` and `options/1`.
  The apply function is responsible for modifying the query to achieve the desired filter state, while
  the options function determines the "values" the filter may have.  Let's look at the
  `PublishedStatus` filter:

  ```
  defmodule PortfolioWeb.ExTeal.Filters.PublishedStatus do
    use ExTeal.Filter

    import Ecto.Query, only: [from: 2]

    def title, do: "Foo Bar"
    def key, do: "foo"

    def apply_filter(_conn, query, value) do
      from(q in query, where: q.published == ^value)
    end

    def options(_conn) do
      [
        %{value: 1, name: "Published"},
        %{value: 0, name: "Draft"}
      ]
    end

    defp to_bool(1), do: {:ok, true}
    defp to_bool(0), do: {:ok, false}
    defp to_bool(_), do: :error
  end
  ```

  Notice that because the params for the filter are encoded as query params they should be url safe and handled as url params.
  """

  @callback options(Plug.Conn.t()) :: list()

  defmacro __using__(_) do
    quote do
      @behaviour ExTeal.Filter
      alias ExTeal.Filter

      @implied_title Phoenix.Naming.resource_name(__MODULE__)
      @implied_key Phoenix.Naming.underscore(@implied_title)

      def title, do: @implied_title
      def key, do: @implied_key

      def build_for(conn), do: Filter.build_for(__MODULE__, conn)

      def options(_conn), do: []
      defoverridable options: 1, title: 0, key: 0
    end
  end

  def build_for(filter_module, conn) do
    %{
      current_value: "",
      key: filter_module.key(),
      title: filter_module.title(),
      options: filter_module.options(conn)
    }
  end

  def filter_for_key(filters, key) do
    Enum.find(filters, fn x ->
      x.key() == key
    end)
  end
end
