defmodule Demo.Populator do
  import Ecto.Query

  alias Demo.Repo

  def reset do
    teardown()
    run()
  end

  def run do
    Enum.each(1..5, fn _ ->
      %Demo.Accounts.User{
        name: Faker.Person.name(),
        email: "#{Ecto.UUID.generate()}@example.com",
        settings: %{},
        active: true,
        birth_date: ~D[1999-12-31],
        stars_count: Enum.random(0..100),
        private_data: %{}
      }
      |> Demo.Repo.insert!()
    end)
  end

  defp teardown do
    Repo.delete_all(Demo.Accounts.User)
    # Repo.delete_all(Demo.Posts.Post)
    # Repo.delete_all(Demo.Accounts.User.Profile)
  end
end
