defmodule ExTeal.Application.Configuration do
  @moduledoc """
  Defines a behavior for configuring the main teal application.

  It relies on (and uses):
  """

  alias ExTeal.{Dashboard, Resource}

  @doc """
  Returns the name of the teal application that is used in the html titles of all pages.
  """
  @callback application_name() :: String.t()

  @doc """
  Returns the path to the logo that is used in the admin panel.
  """
  @callback logo_image_path() :: String.t()

  @doc """
  Returns an array of dashboards
  """
  @callback dashboards() :: [module()]

  @doc """
  Returns the json configuration required for the vue app.
  """
  @callback json_configuration(Plug.Conn.t()) :: map()

  @doc """
  Define the order in which groups are shown in the sidebar.  By default only the
  general 'Resources' group is used, but by overriding the `nav_groups/1` function in the manifest,
  you can define the order of the groups.
  """
  @callback nav_groups(Plug.Conn.t()) :: [String.t()]

  @doc """
  Returns the base path that the teal app is located.
  """
  @callback path() :: String.t()

  defmacro __using__(_) do
    quote do
      alias ExTeal.Application.Configuration
      alias ExTeal.WelcomeDashboard

      @behaviour Configuration

      def application_name, do: "ExTeal"

      def logo_image_path, do: "/teal/images/logo.svg"

      def path, do: "/teal"

      def dashboards, do: [WelcomeDashboard]

      def json_configuration(conn), do: Configuration.parse_json(conn)

      def nav_groups(_conn), do: ["Resources"]

      def auth_provider, do: ExTeal.GuestAuthProvider

      def theme, do: %ExTeal.Theme{}

      defoverridable(
        application_name: 0,
        logo_image_path: 0,
        json_configuration: 1,
        auth_provider: 0,
        path: 0,
        dashboards: 0,
        nav_groups: 1,
        theme: 0
      )
    end
  end

  @spec parse_json(Plug.Conn.t()) :: map()
  def parse_json(conn) do
    %{
      name: ExTeal.application_name(),
      logo: ExTeal.logo_image_path(),
      path: ExTeal.path(),
      resources: ExTeal.available_resources() |> Resource.map_to_json(conn),
      dashboards: ExTeal.available_dashboards() |> Dashboard.map_to_json(),
      nav_groups: ExTeal.available_nav_groups(conn),
      plugins: ExTeal.available_plugins(),
      authenticated: true,
      theme: ExTeal.theme()
    }
  end
end
