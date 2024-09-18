defmodule ElixirCacheServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
require Logger

  use Application
  @impl true
  def start(_type, _args) do
    args = OptionParser.parse(System.argv(), strict: [port: :integer, origin: :string]) |> elem(0)
    Logger.info("Starting the application with args: #{inspect(args)}")
    ElixirCacheServer.Cache.newCache()
    children = [
      {Plug.Cowboy, scheme: :http, plug: ElixirCacheServer.CachePlug, options: [port: args[:port]]}
      # Starts a worker by calling: ElixirCacheServer.Worker.start_link(arg)
      # {ElixirCacheServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirCacheServer.Supervisor]

    Logger.info("Starting the application")
    Supervisor.start_link(children, opts)
  end


end
