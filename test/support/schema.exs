defmodule TestExTeal.User do
  use Ecto.Schema

  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:role, Ecto.Enum, values: [:admin, :moderator, :seller, :buyer])
    field(:post_count, :integer, virtual: true)

    has_many(:posts, TestExTeal.Post)
    has_many(:edited_posts, TestExTeal.Post, foreign_key: :editor_id)
    has_many(:post_likes, through: [:posts, :likes])
    many_to_many(:preferred_tags, TestExTeal.Tag, join_through: TestExTeal.PreferredTag)

    timestamps()
  end
end

defmodule TestExTeal.Features do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:show_featured_image, :boolean, default: true)
    field(:show_cta, :boolean, default: true)
  end

  def changeset(field, params) do
    cast(field, params, [
      :show_featured_image,
      :show_cta
    ])
  end
end

defmodule TestExTeal.Location do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:address, :string)
    field(:address_line_2, :string)
    field(:city, :string)
    field(:state, :string)
    field(:zip, :string)
    field(:primary, :boolean)
  end

  def changeset(field, params) do
    cast(field, params, [
      :address,
      :address_line_2,
      :city,
      :state,
      :zip,
      :primary
    ])
  end
end

defmodule TestExTeal.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestExTeal.{Features, Location, Post}

  schema "posts" do
    field(:name, :string)
    field(:body, :string)
    field(:author, :string)
    field(:contributor, :string)
    field(:published, :boolean)
    field(:published_at, :naive_datetime)
    field(:featured_on, :date)
    field(:deleted_at, :utc_datetime)

    embeds_one(:features, Features, on_replace: :update)
    embeds_one(:location, Location)

    many_to_many(:tags, TestExTeal.Tag, join_through: "posts_tags", on_replace: :delete)

    belongs_to(:user, TestExTeal.User)
    belongs_to(:editor, TestExTeal.User, foreign_key: :editor_id)

    has_many(:authors_posts, through: [:user, :posts])
    has_many(:likes, TestExTeal.Like)

    timestamps()
  end

  @fields ~w(name body author contributor published published_at featured_on deleted_at user_id editor_id)a

  def changeset(%Post{} = post, params \\ %{}) do
    post
    |> cast(params, @fields)
    |> cast_embed(:features)
    |> validate_required([:name])
  end
end

defmodule TestExTeal.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestExTeal.Tag

  schema "tags" do
    field(:name, :string)
    field(:tag_type, :string)
    many_to_many(:posts, TestExTeal.Post, join_through: "posts_tags", on_replace: :delete)

    many_to_many(:users, TestExTeal.User,
      join_through: TestExTeal.PreferredTag,
      on_replace: :delete
    )

    timestamps()
  end

  def changeset(%Tag{} = tag, params \\ %{}) do
    tag
    |> cast(params, [:name, :tag_type])
    |> validate_required([:name])
  end
end

defmodule TestExTeal.PreferredTag do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestExTeal.{PreferredTag, Tag, User}

  schema "preferred_tags" do
    field(:notes, :string)
    field(:order, :integer)
    belongs_to(:user, User)
    belongs_to(:tag, Tag)
    timestamps()
  end

  @fields ~w(user_id tag_id order notes)a

  def changeset(%PreferredTag{} = pt, params \\ %{}) do
    pt
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:tag)
  end
end

defmodule TestExTeal.FailingOnDeletePost do
  use Ecto.Schema

  schema "posts" do
    field(:name, :string)
    field(:body, :string)
    field(:published, :boolean)

    belongs_to(:user, TestExTeal.User)

    timestamps()
  end

  def changeset(_model, params) do
    model = %__MODULE__{
      name: params["name"],
      body: params["body"]
    }

    %Ecto.Changeset{
      types: [name: :string],
      data: model,
      valid?: false,
      errors: [name: "something went wrong"]
    }
  end
end

defmodule TestExTeal.Order do
  use Ecto.Schema

  schema "orders" do
    field(:name, :string)
    field(:grand_total, :integer)
    timestamps()
  end
end

defmodule TestExTeal.Like do
  use Ecto.Schema

  schema "likes" do
    field(:identifier, :string)
    belongs_to(:post, TestExTeal.Post)
  end
end

defmodule TestExTeal.SinglePostUser do
  use Ecto.Schema

  schema "users" do
    field(:email, :string)

    has_one(:post, TestExTeal.Post, foreign_key: :user_id)

    timestamps()
  end
end

defmodule TestExTeal.Song do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  schema("songs") do
    field(:name, :string)

    embeds_one :artist, Artist do
      field(:name, :string)
      field(:age, :integer)
      field(:genre, :string)
      field(:award_winning, :boolean, default: false)
    end

    embeds_many :musicians, Musician do
      field(:name, :string)
      field(:instrument, :string)
    end

    timestamps()
  end

  def changeset(%Song{} = song, params \\ %{}) do
    song
    |> cast(params, [:name])
    |> cast_embed(:artist, &artist_changeset/2)
    |> cast_embed(:musicians, &musician_changeset/2)
    |> validate_required([:name, :artist])
  end

  def artist_changeset(schema, params) do
    schema
    |> cast(params, [:name, :age, :genre, :award_winning])
    |> validate_required([:name, :age, :genre])
  end

  def musician_changeset(schema, params) do
    schema
    |> cast(params, [:name, :instrument])
    |> validate_required([:name, :instrument])
  end
end
