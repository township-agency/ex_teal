defmodule ExTeal.View do
  @moduledoc """
  Returns HTML to render as the main interface of Teal.
  """
  require EEx

  def render(conn) do
    base = Application.get_env(:ex_teal, :base_url)
    use_compiled_assets = Application.get_env(:ex_teal, :compiled_assets, true)
    config = ExTeal.json_configuration()
    auth_provider = ExTeal.auth_provider()

    user = apply(auth_provider, :current_user_for, [conn])

    index(
      title: ExTeal.application_name(),
      base: base,
      config: config,
      user: user,
      compiled_assets: use_compiled_assets,
      plugin_scripts: ExTeal.all_scripts()
    )
  end

  EEx.function_from_file(:def, :index, Path.expand("./lib/ex_teal/templates/index.html.eex"), [
    :assigns
  ])
end
