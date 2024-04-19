defmodule Demo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :active, :boolean
    field :birth_date, :date
    field :stars_count, :integer
    field :private_data, :map
    field :status, Ecto.Enum, values: [:active, :suspended]
    field :roles, {:array, Ecto.Enum}, values: [:admin, :staff]
    field :rating, :float

    embeds_one :settings, Demo.Accounts.User.Settings, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :name, :active, :birth_date, :stars_count, :private_data, :status, :roles, :rating])
    |> cast_embed(:settings, with: &Demo.Accounts.User.Settings.changeset/2)
    |> validate_required([:full_name])
    |> validate_email(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Quack.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end
end

defmodule Demo.Accounts.User.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :some_option, :string

    embeds_many :configs, __MODULE__.Config, on_replace: :delete
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:some_option])
    |> cast_embed(:configs, with: &Demo.Accounts.User.Settings.Config.changeset/2)
  end
end

defmodule Demo.Accounts.User.Settings.Config do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :key, :string
    field :val, :string

    field :good, :boolean
    field :legal, :boolean
  end

  def changeset(config, attrs) do
    config
    |> cast(config, attrs, [:key, :val, :good, :legal])
    |> validate_required([:key, :val])
  end
end
