defmodule ExTeal.View do
  @moduledoc """
  Returns HTML to render as the main interface of Teal.
  """
  require EEx

  def render(conn) do
    base =
      case Application.fetch_env(:ex_teal, :base_url) do
        {:ok, base} -> base
        :error -> "/"
      end

    config = ExTeal.json_configuration(conn)
    auth_provider = ExTeal.auth_provider()

    user = auth_provider.current_user_for(conn)
    dropdown = auth_provider.dropdown_content(conn)

    assets = ExTeal.Asset.all_assets()
    csrf_token = Plug.CSRFProtection.get_csrf_token()

    theme = ExTeal.theme()
    color_variables = ExTeal.Theme.color_variables(theme)

    index(
      title: ExTeal.application_name(),
      base: base,
      config: config,
      user: user,
      assets: assets,
      plugin_scripts: ExTeal.all_scripts(),
      plugin_styles: ExTeal.all_styles(),
      csrf_token: csrf_token,
      dropdown: dropdown,
      colors: color_variables
    )
  end

  EEx.function_from_file(:def, :index, Path.expand("./lib/ex_teal/templates/index.html.eex"), [
    :assigns
  ])
end
