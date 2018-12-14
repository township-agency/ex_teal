defmodule TestExTeal.PublishAction do
  use ExTeal.Action

  alias TestExTeal.{Post, Repo}

  def title, do: "Publish Post"
  def key, do: "publish-post"

  def commit(_conn, _fields, resources) do
    save_all =
      resources
      |> Enum.map(&mark_as_published/1)
      |> Enum.all?(fn {val, _} -> val == :ok end)

    case save_all do
      true -> Action.message("Marked #{length(resources)} as Published")
      false -> Action.error("Unable to publish the posts")
    end
  end

  defp mark_as_published(resource) do
    resource
    |> Post.changeset(%{published: true})
    |> Repo.update()
  end
end
