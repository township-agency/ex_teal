defmodule TestExTeal.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias Phoenix.ConnTest
  alias TestExTeal.Repo

  defmacro test_manifests(manifests, do: block) do
    quote do
      for {atom, title} <- unquote(manifests) do
        @tag manifest: atom
        test title do
          unquote(block)
        end
      end
    end
  end

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest

      alias TestExTeal.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]

      import TestExTealWeb.Router.Helpers
      import TestExTeal.Factory

      # The default endpoint for testing
      @endpoint TestExTealWeb.Endpoint
    end
  end

  setup tags do
    unless tags[:async] do
      Sandbox.checkout(Repo)
    end

    if Map.has_key?(tags, :manifest) do
      Application.put_env(:ex_teal, :manifest, Map.get(tags, :manifest))
    end

    on_exit(fn ->
      Application.put_env(:ex_teal, :manifest, nil)
    end)

    {:ok, conn: ConnTest.build_conn()}
  end
end
