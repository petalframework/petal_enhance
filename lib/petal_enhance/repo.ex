defmodule PetalEnhance.Repo do
  use Ecto.Repo,
    otp_app: :petal_enhance,
    adapter: Ecto.Adapters.Postgres
end
