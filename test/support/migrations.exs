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
  end
end
