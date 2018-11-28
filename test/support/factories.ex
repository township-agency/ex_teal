defmodule TestExTeal.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: TestExTeal.Repo

  alias TestExTeal.{Post, User}

  def user_factory do
    %User{
      name: "Motel ExTeal",
      email: "teal@motel.is"
    }
  end

  def post_factory do
    %Post{
      name: "Testing Post",
      body: "Bacon Ipsum Lorem",
      published: true,
      user: build(:user)
    }
  end
end
