defmodule ExTeal.AuthProvider do
  @moduledoc """
  Interface for providing authorization and authentication to ExTeal.
  """

  @typedoc """
  Data to be displayed on the front end
  """
  @type user_payload :: %{
          name: String.t() | nil,
          avatar_url: String.t() | nil
        }

  @doc """
  Used to display the current user on the nav bar.

  Should return a user_payload map.  If your User struct
  does not have a user image associated with it, consider using the gravatar api.
  """
  @callback current_user_for(Plug.Conn.t()) :: user_payload

  @doc """
  Used to build the content of the dropdown menu for a user.

  The content of the user dropdown is dynamic and can be overriden to provide
  additional links and html.

  The function should return a list of strings that will be used to build list
  elements.
  """
  @callback dropdown_content(Plug.Conn.t()) :: [String.t()]

  defmacro(__using__(_opts)) do
    quote do
      @behaviour ExTeal.AuthProvider
      def current_user_for(_), do: %{name: nil, avatar_url: nil}

      def dropdown_content(_conn), do: ["<a href=\"/auth/logout\">Logout</a>"]

      defoverridable(current_user_for: 1, dropdown_content: 1)
    end
  end
end
