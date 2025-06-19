defmodule SnapSafe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SnapSafeWeb.Telemetry,
      SnapSafe.Repo,
      {DNSCluster, query: Application.get_env(:snap_safe, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SnapSafe.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SnapSafe.Finch},
      # Start a worker by calling: SnapSafe.Worker.start_link(arg)
      # {SnapSafe.Worker, arg},
      # Start to serve requests, typically the last entry
      SnapSafeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SnapSafe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SnapSafeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
