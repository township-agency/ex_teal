defmodule ExTeal.Application.Configuration do
  @moduledoc """
  Defines a behavior for configuring the main teal application.

  It relies on (and uses):
  """

  alias ExTeal.Resource

  @doc """
  Returns the name of the teal application that is used in the html titles of all pages.
  """
  @callback application_name() :: String.t()

  @doc """
  Returns the path to the logo that is used in the admin panel.
  """
  @callback logo_image_path() :: String.t()

  @doc """
  Returns the json configuration required for the vue app.
  """
  @callback json_configuration() :: map()

  @doc """
  Returns the base path that the teal app is located.
  """
  @callback path() :: String.t()

  defmacro __using__(_) do
    quote do
      alias ExTeal.Application.Configuration

      @behaviour Configuration

      def application_name, do: "ExTeal"

      def logo_image_path, do: "/teal/images/logo.svg"

      def path, do: "/teal"

      def json_configuration, do: Configuration.parse_json()

      def auth_provider, do: ExTeal.GuestAuthProvider

      defoverridable(
        application_name: 0,
        logo_image_path: 0,
        json_configuration: 0,
        auth_provider: 0,
        path: 0
      )
    end
  end

  def parse_json do
    %{
      version: "0.1.0",
      name: ExTeal.application_name(),
      logo: ExTeal.logo_image_path(),
      path: ExTeal.path(),
      resources: ExTeal.available_resources() |> Resource.map_to_json(),
      plugins: ExTeal.available_plugins(),
      authenticated: true
    }
  end
end
