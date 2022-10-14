defmodule PetalEnhanceWeb.Routes do
  """
  ## Usage
  ```elixir
  # lib/my_app_web/router.ex
  use MyAppWeb, :router
  import PetalEnhanceWeb.Routes
  ...
  scope "/" do
    pipe_through :browser
    live_petal_enhance "/__enhance"
  end
  ```
  """
  defmacro petal_enhance_dashboard(path, opts \\ []) do
    opts = Keyword.put(opts, :application_router, __CALLER__.module)

    quote bind_quoted: binding() do
      scope path, alias: false, as: false do
        import Phoenix.LiveView.Router, only: [live: 4, live_session: 3]

        pipeline :petal_enhance_browser do
          plug(:accepts, ["html"])
          plug(:fetch_session)
          plug(:protect_from_forgery)
        end

        scope path: "/" do
          pipe_through(:petal_enhance_browser)

          live_session :petal_enhance, [
            root_layout: {PetalEnhanceWeb.LayoutView, :root}
          ] do
            live "/", PetalEnhanceWeb.DashboardLive, :index, as: :petal_enhance
            live "/recipes/:id", PetalEnhanceWeb.DashboardLive, :show, as: :petal_enhance
            live "/recipes/:id/diff", PetalEnhanceWeb.DashboardLive, :diff, as: :petal_enhance
            live "/recipes/:id/apply", PetalEnhanceWeb.DashboardLive, :apply, as: :petal_enhance
            live "/recipes/tags/:tag", PetalEnhanceWeb.DashboardLive, :tag, as: :petal_enhance
            live "/categories/:category", PetalEnhanceWeb.DashboardLive, :category, as: :petal_enhance
          end
        end
      end
    end
  end
end
