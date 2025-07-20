defmodule Poke.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PokeWeb.Telemetry,
      Poke.Repo,
      {DNSCluster, query: Application.get_env(:poke, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Poke.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Poke.Finch},
      # Start a worker by calling: Poke.Worker.start_link(arg)
      # {Poke.Worker, arg},
      # Start to serve requests, typically the last entry
      PokeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Poke.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PokeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
