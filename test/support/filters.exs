defmodule TestExTeal.PublishedStatus do
  @moduledoc false
  use ExTeal.Filter

  import Ecto.Query, only: [from: 2]

  def apply_query(_conn, query, value) do
    case to_bool(value) do
      {:ok, val} ->
        from(q in query, where: q.published == ^val)

      _ ->
        query
    end
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
