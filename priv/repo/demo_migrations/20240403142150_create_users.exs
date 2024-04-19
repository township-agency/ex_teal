defmodule Demo.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users) do
      add :name, :string
      add :email, :citext, null: false
      add :settings, :map, default: %{}
      add :active, :boolean, default: true, null: false
      add :birth_date, :date
      add :stars_count, :integer
      add :status, :string
      add :private_data, :map, default: %{}
      add :roles, {:array, :string}, default: [], null: false
      add :rating, :float
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
