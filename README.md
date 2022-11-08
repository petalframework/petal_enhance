# Petal Enhance

## Install

1. Install dep:

```elixir
# mix.exs

{:petal_enhance, git: "https://github.com/petalframework/petal_enhance", only: :dev},
```

2. Add route

```elixir
# router.ex

  scope "/" do
    pipe_through :browser
    petal_enhance_dashboard "/_enhance"
  end
```

3. Create a project on [petal.build](https://petal.build)


4. Copy your env vars

```
# .envrc
export PETAL_BUILD_PROJECT=""
export PETAL_BUILD_API_TOKEN=""
```

5. Browse recipes and apply them

[http://localhost:4000/_enhance](http://localhost:4000/_enhance)

