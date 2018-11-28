defmodule TestExTeal.User do
  use Ecto.Schema

  schema "users" do
    field(:email, :string)
    field(:name, :string)
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
