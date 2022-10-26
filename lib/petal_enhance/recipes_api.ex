defmodule PetalEnhance.RecipesApi do
  alias PetalEnhance.Utils

  def all() do
    case Tesla.get(client(), "/recipes") do
      {:ok, %Tesla.Env{status: 200} = env} ->
        {:ok, Utils.atomize_keys(env.body)}
      {:ok, %Tesla.Env{status: 401} = env} ->
        {:error, env.body["error"]}
      rest ->
        rest
    end
  end

  def get(id) do
    case Tesla.get(client(), "/recipes/#{id}") do
      {:ok, %Tesla.Env{status: 200} = env} ->
        {:ok, Utils.atomize_keys(env.body)}
      rest ->
        rest
    end
  end

  def log_event(params) do
    case Tesla.post(client(), "/log", params) do
      {:ok, %Tesla.Env{status: 200}} ->
        {:ok, params}
      rest ->
        rest
    end
  end

  def client() do
    token = Application.get_env(:petal_enhance, :api_token)
    project = Application.get_env(:petal_enhance, :project)
    host = Application.get_env(:petal_enhance, :petal_build_host, "https://petal.build")
    base_url = host <> "/api"

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [
        {"authorization", "token: " <> token},
        {"project", project}
      ]}
    ]

    Tesla.client(middleware)
  end
end
