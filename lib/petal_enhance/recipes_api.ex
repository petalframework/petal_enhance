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
    token = System.get_env("PETAL_BUILD_API_TOKEN")
    host = System.get_env("PETAL_BUILD_HOST", "https://petal.build")
    base_url = host <> "/api"

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"authorization", "token: " <> (token || "") }]}
    ]

    Tesla.client(middleware)
  end

  def list() do
    [
      %{
        id: "uuid",
        label: "UUID",
        description:
          "Use UUIDs instead of sequential integers for IDs (all tables). Modifies migration files.",
        tags: ["database", "ecto", "setup"]
      },
      %{
        id: "first-name-last-name",
        label: "User first name & last name",
        description:
          "Change `user.name` to `user.first_name` and `user.last_name`. Modifies migration files.",
        tags: ["database", "ecto", "user", "setup"]
      },
      %{
        id: "npm",
        label: "NPM package manager",
        tags: ["javascript", "core"],
        description:
          "app.js can import NPM packages. They will be stored in `assets/node_modules`."
      }
    ]
  end
end
