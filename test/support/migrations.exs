defmodule TestExTeal.Migrations do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string)
      add(:name, :string)
      add(:password_hash, :string)
      timestamps()
    end

    create table(:posts) do
      add(:name, :string)
      add(:body, :string)
      add(:user_id, references(:users))
      add(:published, :boolean, default: false, null: false)

      timestamps()
    end

    create table(:tags) do
      add(:name, :string)

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
  end
end
