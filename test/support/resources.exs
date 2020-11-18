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

  alias ExTeal.Fields.{
    BelongsTo,
    Boolean,
    BooleanGroup,
    DateTime,
    ID,
    ManyToMany,
    Select,
    Text,
    TextArea
  }

  def model, do: TestExTeal.Post

  def with, do: [:user]

  def fields,
    do: [
      ID.make(:id),
      Text.make(:name),
      TextArea.make(:body),
      Boolean.make(:published),
      Select.make(:author) |> Select.options(Foo: "foo", Bar: "bar"),
      Select.make(:contributor) |> Select.options(~w(foo bar)),
      DateTime.make(:published_at),
      DateTime.make(:deleted_at),
      BelongsTo.make(:user),
      BooleanGroup.make(:features)
      |> BooleanGroup.options(%{
        "show_cta" => "Show CTA",
        "show_featured_image" => "Show Featured Image"
      }),
      ManyToMany.make(:tags, TestExTeal.Tag)
    ]

  def actions(_), do: [TestExTeal.PublishAction]
end

defmodule TestExTeal.TagResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{ManyToMany, Text}

  def model, do: TestExTeal.Tag

  def search, do: [:name]

  def fields,
    do: [
      Text.make(:name),
      ManyToMany.make(:posts, TestExTeal.Post)
    ]
end

defmodule TestExTeal.SinglePostUserResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{HasOne, ID}

  def model, do: TestExTeal.SinglePostUser

  def fields,
    do: [
      ID.make(:id),
      HasOne.make(:post, TestExTeal.Post)
    ]
end
