defmodule ExTeal.Cards.Greeting do
  @moduledoc """
  Not the thing you get the mail, but a card that appears
  on the dashboard.
  """
  alias Plug.Conn

  @doc """
  Greeting for a user viewing the card.  Defaults to 'Welcome back,'
  """
  @callback greeting() :: String.t()

  @doc """
  The users title, useful in applications with RBAC or permissions
  """
  @callback user_title(Conn.t()) :: String.t() | nil

  @doc """
  The name to greet the user by, use the conn to pull the
  currently authorized user.
  """
  @callback user_name(Conn.t()) :: String.t() | nil

  @doc """
  64px x 64px image url to display next to the greeting
  """
  @callback avatar_url(Conn.t()) :: String.t() | nil

  @doc """
  Potentially HTML Rich text to display below the users title.
  Beware any unescaped / unsanitary HTML.
  """
  @callback helper_text(Conn.t()) :: String.t() | nil

  @typedoc """
  Each link should be a map with the following keys:
    - `label` (required) the text to display on the link
    - `url` (required) the url to link to
    - `button_classes` (optional) a string of classes to apply to the link

  Buttons default to a btn btn-default btn-secondary class definition if an override is not provided
  """
  @type link :: %{
          optional(:button_classes) => String.t() | nil,
          label: String.t(),
          url: String.t()
        }

  @doc """
   A list of links to display on a greeting card.
  """
  @callback links(Conn.t()) :: [link()]

  defmacro(__using__(_opts)) do
    quote do
      @behaviour ExTeal.Cards.Greeting
      use ExTeal.Card

      @impl true
      def component, do: "cards-greeting"

      @impl true
      def greeting, do: "Welcome back,"

      @impl true
      def user_title(_), do: nil

      @impl true
      def user_name(_), do: nil

      @impl true
      def avatar_url(_), do: nil

      @impl true
      def helper_text(_), do: nil

      @impl true
      def links(_), do: []

      @impl true
      def options(conn),
        do: %{
          greeting: greeting(),
          user_title: user_title(conn),
          user_name: user_name(conn),
          avatar_url: avatar_url(conn),
          links: links(conn),
          helper_text: helper_text(conn)
        }

      defoverridable greeting: 0,
                     user_title: 1,
                     user_name: 1,
                     avatar_url: 1,
                     links: 1,
                     helper_text: 1
    end
  end
end
