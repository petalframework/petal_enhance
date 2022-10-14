defmodule PetalEnhanceWeb.LayoutView do
  use PetalEnhanceWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_petal_enhance_path, 2}}
end
