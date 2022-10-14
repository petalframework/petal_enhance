defmodule PetalEnhanceWeb.PageController do
  use PetalEnhanceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
