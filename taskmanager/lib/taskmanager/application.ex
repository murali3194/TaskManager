defmodule Taskmanager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TaskmanagerWeb.Telemetry,
      # Start the Ecto repository
      Taskmanager.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Taskmanager.PubSub},
      # Start Finch
      {Finch, name: Taskmanager.Finch},
      # Start the Endpoint (http/https)
      TaskmanagerWeb.Endpoint
      # Start a worker by calling: Taskmanager.Worker.start_link(arg)
      # {Taskmanager.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Taskmanager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TaskmanagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
