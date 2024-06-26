defmodule TestExTeal.UserResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{HasMany, ID, ManyToMany, Number, Select, Text}

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
      Select.make(:role),
      HasMany.make(:posts),
      HasMany.make(:edited_posts),
      HasMany.make(:post_likes),
      ManyToMany.make(:preferred_tags, TestExTeal.Tag)
      |> ManyToMany.with_index_fields([
        Text.make(:name),
        Select.make(:tag_type) |> Select.options(~w(foo bar))
      ])
      |> ManyToMany.with_pivot_fields([
        Number.make(:order),
        Text.make(:notes) |> hide_when_updating()
      ])
      |> ManyToMany.sortable_by(:order)
    ]

  def default_order, do: [asc: :name]
end

defmodule TestExTeal.PostResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{
    BelongsTo,
    Boolean,
    BooleanGroup,
    DateTime,
    HasMany,
    ID,
    ManyToMany,
    Select,
    Text,
    TextArea
  }

  def model, do: TestExTeal.Post

  def with, do: [:user, :editor]

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
      BelongsTo.make(:user, TestExTeal.User),
      BelongsTo.make(:editor, TestExTeal.User),
      BooleanGroup.make(:features)
      |> BooleanGroup.options(%{
        "show_cta" => "Show CTA",
        "show_featured_image" => "Show Featured Image"
      }),
      ManyToMany.make(:tags, TestExTeal.Tag),
      HasMany.make(:authors_posts)
    ]

  def actions(_), do: [TestExTeal.PublishAction]

  def default_order, do: [asc: :name]
end

defmodule TestExTeal.PostEmbedResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{
    Boolean,
    DateTime,
    ID,
    Select,
    Text
  }

  alias ExTeal.Embedded

  def model, do: TestExTeal.Post

  def uri, do: "post-embeds"

  def fields,
    do: [
      Text.make(:name),
      Embedded.new(:location, [
        Text.make(:address),
        Text.make(:city),
        Text.make(:state),
        Text.make(:zip),
        Boolean.make(:primary)
      ])
    ]
end

defmodule TestExTeal.TagResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{ManyToMany, Select, Text}

  def model, do: TestExTeal.Tag

  def search, do: [:name]

  def fields,
    do: [
      Text.make(:name),
      Select.make(:tag_type) |> Select.options(~w(foo bar)),
      ManyToMany.make(:posts, TestExTeal.Post)
    ]

  def default_order, do: [asc: :name]
end

defmodule TestExTeal.OrderResourde do
  use ExTeal.Resource
  alias ExTeal.Fields.Number

  def model, do: TestExTeal.Order

  def fields, do: [Number.make(:grand_total)]
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

defmodule TestExTeal.Invisible.PostResource do
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

  def policy, do: TestExTeal.InvisiblePolicy

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

defmodule TestExTeal.Enough.PostResource do
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

  def policy, do: TestExTeal.EnoughPolicy

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

defmodule TestExTeal.Immutable.PostResource do
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

  def policy, do: TestExTeal.ImmutablePolicy

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

defmodule TestExTeal.Forever.PostResource do
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

  def policy, do: TestExTeal.ForeverPolicy

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
      BooleanGroup.make(:features)
      |> BooleanGroup.options(%{
        "show_cta" => "Show CTA",
        "show_featured_image" => "Show Featured Image"
      }),
      ManyToMany.make(:tags, TestExTeal.Tag)
    ]

  def actions(_), do: [TestExTeal.PublishAction]
end

defmodule TestExTeal.UsersWithPostCountsResource do
  use ExTeal.Resource
  import Ecto.Query
  alias ExTeal.Field

  alias ExTeal.Fields.{HasMany, ID, Number, Text}

  def model, do: TestExTeal.User

  def records(_conn, _resource) do
    TestExTeal.User
    |> join(:left, [u], p in assoc(u, :posts))
    |> group_by([u], u.id)
    |> select([u, p], %{
      id: u.id,
      name: u.name,
      post_count: p.id |> count() |> selected_as(:post_count)
    })
  end

  def fields,
    do: [
      Text.make(:name),
      Number.make(:post_count) |> Field.virtual(),
      HasMany.make(:posts)
      |> HasMany.with_index_fields([
        ID.make(),
        Text.make(:name)
      ])
    ]

  def uri, do: "users"
end

defmodule TestExTeal.LikeResource do
  use ExTeal.Resource
  alias ExTeal.Fields.{BelongsTo, Text}

  def model, do: TestExTeal.Like

  def with, do: [:post]

  def fields,
    do: [
      Text.make(:identifier),
      BelongsTo.make(:post, TestExTeal.Post)
    ]
end
