defmodule TestExTeal.User do
  use Ecto.Schema

  schema "users" do
    field(:email, :string)
    field(:name, :string)

    many_to_many(:preferred_tags, TestExTeal.Tag, join_through: TestExTeal.PreferedTag)
    timestamps()
  end
end

defmodule TestExTeal.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestExTeal.Post

  schema "posts" do
    field(:name, :string)
    field(:body, :string)
    field(:published, :boolean)

    many_to_many(:tags, TestExTeal.Tag, join_through: "posts_tags")

    belongs_to(:user, TestExTeal.User)

    timestamps()
  end

  @fields ~w(name body published user_id)a

  def changeset(%Post{} = post, params \\ %{}) do
    post
    |> cast(params, @fields)
    |> validate_required([:name])
  end
end

defmodule TestExTeal.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestExTeal.Tag

  schema "tags" do
    field(:name, :string)
    timestamps()
  end

  def changeset(%Tag{} = tag, params \\ %{}) do
    tag
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end

defmodule TestExTeal.PreferredTag do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestExTeal.{PreferredTag, Tag, User}

  schema "preferred_tags" do
    field(:order, :integer)
    belongs_to(:user, User)
    belongs_to(:tag, Tag)
    timestamps()
  end

  @fields ~w(user_id tag_id order)a

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
