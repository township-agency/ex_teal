defmodule TestExTeal.FeatureCase do
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias TestExTeal.Repo

  using do
    quote do
      use Hound.Helpers

      alias TestExTeal.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
      import TestExTealWeb.Router.Helpers
      import TestExTeal.Factory
    end
  end

  setup tags do
    Application.put_env(:ex_teal, :index_path, "../../priv/static/index.html")
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
