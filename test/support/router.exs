defmodule TestExTealWeb.Router do
  use Phoenix.Router

  pipeline :browser do
    plug(:accepts, ["html", "text"])
    plug(:fetch_session)
    plug(:fetch_flash)
    # plug :protect_from_forgery
    plug(:put_secure_browser_headers)
  end

  scope "/" do
    pipe_through(:browser)
    get("/dummies", TestExTealWeb.DummyController, :index)
  end
end
