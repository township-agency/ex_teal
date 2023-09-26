defmodule TestExTeal.Migrations do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE user_role AS ENUM ('admin', 'moderator', 'seller', 'buyer')"
    drop_query = "DROP TYPE user_role"
    execute(create_query, drop_query)

    create table(:users) do
      add(:email, :string)
      add(:name, :string)
      add(:password_hash, :string)
      add(:role, :user_role)
      timestamps()
    end

    create table(:posts) do
      add(:name, :string)
      add(:body, :string)
      add(:author, :string)
      add(:contributor, :string)
      add(:features, :map)
      add(:location, :map)
      add(:user_id, references(:users))
      add(:published, :boolean, default: false, null: false)
      add(:published_at, :naive_datetime)
      add(:deleted_at, :utc_datetime)

      timestamps()
    end

    create table(:likes) do
      add(:identifier, :string)
      add(:post_id, references(:posts))
    end

    create table(:tags) do
      add(:name, :string)
      add(:tag_type, :string)

      timestamps()
    end

    create table(:orders) do
      add(:name, :string)
      add(:grand_total, :integer)
      timestamps()
    end

    create table(:posts_tags, primary_key: false) do
      add(:post_id, references(:posts))
      add(:tag_id, references(:tags))
    end

    create table(:preferred_tags) do
      add(:user_id, references(:users))
      add(:tag_id, references(:tags))
      add(:notes, :string)
      add(:order, :integer)
      timestamps()
    end

    create table(:songs) do
      add(:name, :string)
      add(:artist, :map, default: %{})
      add(:musicians, :map, default: %{})
      add(:lyrics, {:array, :map}, default: [])
      timestamps()
    end
  end
end
