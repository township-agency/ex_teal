defmodule TestExTeal.UserResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{ID, Text}

  def model, do: TestExTeal.User

  def search, do: [:name]

  def fields,
    do: [
      ID.make(:id),
      Text.make(:name),
      Text.make(:email)
    ]
end

defmodule TestExTeal.PostResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{BelongsTo, Boolean, ID, Text, TextArea}

  def model, do: TestExTeal.Post

  def fields,
    do: [
      ID.make(:id),
      Text.make(:name),
      TextArea.make(:body),
      Boolean.make(:published),
      BelongsTo.make(:user)
    ]

  def filters(_conn), do: [TestExTeal.PublishedStatus]
end
