defmodule DemoWeb.UserAuth do
  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = Phoenix.Component.assign_new(socket, :current_user, fn ->
      Demo.Repo.get(Demo.Accounts.User, session["user_id"])
    end)
    {:cont, socket}
  end
end
