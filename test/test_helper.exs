ExUnit.start()

Application.put_env(:ex_teal, :repo, TestExTeal.Repo)
Application.put_env(:ex_teal, :manifest, TestExTeal.DefaultManifest)
Application.ensure_all_started(:jason)
Application.ensure_all_started(:ex_teal)
{:ok, _} = Application.ensure_all_started(:hound)

Code.require_file("./support/dummy_controller.exs", __DIR__)
Code.require_file("./support/schema.exs", __DIR__)
Code.require_file("./support/repo.exs", __DIR__)
Code.require_file("./support/migrations.exs", __DIR__)
Code.require_file("./support/manifests.exs", __DIR__)
Code.require_file("./support/metrics.exs", __DIR__)
Code.require_file("./support/dashboards.exs", __DIR__)
Code.require_file("./support/router.exs", __DIR__)
Code.require_file("./support/endpoint.exs", __DIR__)
Code.require_file("./support/views.exs", __DIR__)
Code.require_file("./support/conn_case.exs", __DIR__)
Code.require_file("./support/actions.exs", __DIR__)
Code.require_file("./support/resources.exs", __DIR__)
Code.require_file("./support/factories.ex", __DIR__)
Code.require_file("./support/feature_case.exs", __DIR__)

defmodule ExTeal.RepoSetup do
  use ExUnit.CaseTemplate
end

TestExTeal.Repo.__adapter__().storage_down(TestExTeal.Repo.config())
TestExTeal.Repo.__adapter__().storage_up(TestExTeal.Repo.config())

{:ok, _pid} = TestExTealWeb.Endpoint.start_link()
{:ok, _pid} = TestExTeal.Repo.start_link()
_ = Ecto.Migrator.up(TestExTeal.Repo, 0, TestExTeal.Migrations, log: false)
Process.flag(:trap_exit, true)
Ecto.Adapters.SQL.Sandbox.mode(TestExTeal.Repo, :manual)
ExUnit.configure(exclude: :feature)
