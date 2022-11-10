defmodule PetalEnhance.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    if System.get_env("TESTING_LOCALLY") == "true" do
      children = [
        {Phoenix.PubSub, name: PetalEnhance.PubSub},
        PetalEnhanceWeb.Endpoint
      ]
      opts = [strategy: :one_for_one, name: PetalEnhance.Supervisor]
      Supervisor.start_link(children, opts)
    else
      {:ok, self()}
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PetalEnhanceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
