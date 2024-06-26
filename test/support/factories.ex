defmodule TestExTeal.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: TestExTeal.Repo

  alias TestExTeal.{Like, Order, Post, PreferredTag, SinglePostUser, Song, Tag, User}

  def user_factory do
    %User{
      name: "Motel ExTeal",
      email: "teal@motel.is",
      role: :admin
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

  def single_post_user_factory do
    %SinglePostUser{
      email: "foo@gmail.com",
      post: build(:post)
    }
  end

  def tag_factory do
    %Tag{
      name: sequence(:name, &"Tag #{&1}")
    }
  end

  def preferred_tag_factory do
    %PreferredTag{
      user: build(:user),
      tag: build(:tag),
      order: sequence(:order, & &1),
      notes: "foo"
    }
  end

  def order_factory do
    %Order{
      grand_total: 0
    }
  end

  def like_factory do
    %Like{
      post: build(:post),
      identifier: sequence(:identifier, &"#{&1}")
    }
  end

  def song_factory do
    %Song{
      name: sequence(:name, &"Song #{&1}"),
      musicians: [
        %{name: "John", instrument: "guitar"},
        %{name: "Paul", instrument: "bass"},
        %{name: "George", instrument: "guitar"},
        %{name: "Ringo", instrument: "drums"}
      ]
    }
  end
end
