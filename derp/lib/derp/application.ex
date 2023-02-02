defmodule Derp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  alias MyspaceIPFS

  use Application

  # contract :Derp, contract_address: "", abi_path: ""

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Derp.Repo,
      # Start the Telemetry supervisor
      DerpWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Derp.PubSub},
      # Start the Endpoint (http/https)
      DerpWeb.Endpoint,
      # Start a worker by calling: Derp.Worker.start_link(arg)
      # {Derp.Worker, arg}
      Derp.Oracle.EventHandler,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Derp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DerpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
