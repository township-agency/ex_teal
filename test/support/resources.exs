defmodule TestExTeal.UserResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{ID, ManyToMany, Text}

  def model, do: TestExTeal.User

  def search, do: [:name]

  def fields,
    do: [
      ID.make(:id),
      Text.make(:name),
      Text.make(:email),
      ManyToMany.make(:preferred_tags, TestExTeal.Tag)
    ]
end

defmodule TestExTeal.PostResource do
  use ExTeal.Resource
  alias ExTeal.Fields.{BelongsTo, Boolean, ID, ManyToMany, Text, TextArea}

  def model, do: TestExTeal.Post

  def fields,
    do: [
      ID.make(:id),
      Text.make(:name),
      TextArea.make(:body),
      Boolean.make(:published),
      BelongsTo.make(:user),
      ManyToMany.make(:tags, TestExTeal.Tag)
    ]

  def filters(_conn), do: [TestExTeal.PublishedStatus]

  def actions(_), do: [TestExTeal.PublishAction]
end

defmodule TestExTeal.TagResource do
  use ExTeal.Resource

  alias ExTeal.Fields.Text

  def model, do: TestExTeal.Tag

  def fields,
    do: [
      Text.make(:name),
      ManyToMany.make(:posts, TestExTeal.Post)
    ]
end
