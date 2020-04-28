defmodule TestExTeal.UserResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{ID, ManyToMany, Number, Text}

  def model, do: TestExTeal.User

  def search, do: [:name]

  def cards(_conn),
    do: [
      TestExTeal.NewUsersMetric
    ]

  def fields,
    do: [
      ID.make(:id),
      Text.make(:name),
      Text.make(:email),
      ManyToMany.make(:preferred_tags, TestExTeal.Tag)
      |> ManyToMany.with_pivot_fields([
        Number.make(:order),
        Text.make(:notes) |> hide_when_updating()
      ])
      |> ManyToMany.sortable_by(:order)
    ]
end

defmodule TestExTeal.PostResource do
  use ExTeal.Resource
  alias ExTeal.Fields.{BelongsTo, Boolean, DateTime, ID, ManyToMany, Text, TextArea}

  def model, do: TestExTeal.Post

  def with, do: [:user]

  def fields,
    do: [
      ID.make(:id),
      Text.make(:name),
      TextArea.make(:body),
      Boolean.make(:published),
      DateTime.make(:published_at),
      DateTime.make(:deleted_at),
      BelongsTo.make(:user),
      ManyToMany.make(:tags, TestExTeal.Tag)
    ]

  def filters(_conn), do: [TestExTeal.PublishedStatus]

  def actions(_), do: [TestExTeal.PublishAction]
end

defmodule TestExTeal.TagResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{ManyToMany, Text}

  def model, do: TestExTeal.Tag

  def fields,
    do: [
      Text.make(:name),
      ManyToMany.make(:posts, TestExTeal.Post)
    ]
end
