defmodule TestExTeal.PublishAction do
  use ExTeal.Action

  alias ExTeal.ActionResponse
  alias TestExTeal.{Post, Repo}

  def title, do: "Publish Post"
  def key, do: "publish-post"

  def commit(_conn, _fields, query) do
    with [_ | _] = resources <- Repo.all(query),
         {:ok, message} <- batch_publish(resources) do
      ActionResponse.success(message)
    else
      [] ->
        ActionResponse.error("Error not found")

      {:error, message} ->
        ActionResponse.error(message)
    end
  end

  defp batch_publish(resources) do
    save_all =
      resources
      |> Enum.map(&mark_as_published/1)
      |> Enum.all?(fn {val, _} -> val == :ok end)

    case save_all do
      true -> {:ok, "Marked #{length(resources)} as Published"}
      false -> {:error, "Unable to publish the posts"}
    end
  end

  defp mark_as_published(resource) do
    resource
    |> Post.changeset(%{published: true})
    |> Repo.update()
  end
end
