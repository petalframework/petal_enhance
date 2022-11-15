# Petal Enhance

## Petal Pro users

Petal Pro has this project installed already. Follow steps 3 onwards below.

## Normal Phoenix users

1. Install deps:

```elixir
# mix.exs

{:petal_enhance, git: "https://github.com/petalframework/petal_enhance", only: :dev},
```

2. Add route

```elixir
# router.ex
  import PetalEnhanceWeb.Routes

  petal_enhance_dashboard "/_enhance"
```

3. Create a project on [petal.build](https://petal.build)

4. Update your config in `dev.exs`

Use environment variables if you can (eg. `System.get_env("PETAL_BUILD_API_TOKEN")`).

```
config :petal_enhance,
  router_helpers: <YourRouter>.Helpers,
  project: "xxx",
  api_token: "xxx"
```

Replace <YourRouter> with your routers module name. Just open `router.ex` to see it. Usually it's something like `YourAppWeb.Router`.

5. Browse recipes and apply them

[http://localhost:4000/_enhance](http://localhost:4000/_enhance)

