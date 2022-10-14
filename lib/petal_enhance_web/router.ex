defmodule PetalEnhanceWeb.Router do
  use PetalEnhanceWeb, :router
  import PetalEnhanceWeb.Routes

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PetalEnhanceWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/" do
    pipe_through :browser
    petal_enhance_dashboard "/"
  end
end
