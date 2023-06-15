defmodule ExTeal.Resource.Pagination do
  @moduledoc """
  Used to build paginated views of resources
  """
  import Ecto.Query

  def paginate_query(query, conn, resource) do
    per_page = conn.params |> Map.get("per_page", "25") |> String.to_integer()
    page = conn.params |> Map.get("page", "1") |> String.to_integer()

    offset = (page - 1) * per_page

    data_query = from(query, limit: ^per_page, offset: ^offset)

    agg_query =
      query
      |> exclude(:preload)
      |> exclude(:select)
      |> exclude(:order_by)

    agg_query = from(q in subquery(agg_query), select: count(q.id))
    all = resource.repo().one(agg_query)

    total = Float.ceil(all / per_page)

    %{
      results: resource.repo().all(data_query),
      all: all,
      total: trunc(total)
    }
  end
end
