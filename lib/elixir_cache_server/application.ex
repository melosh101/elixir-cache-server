defmodule ElixirCacheServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias ElixirCacheServer.CommandHandler
require Logger

  use Application
  @impl true
  def start(_type, _args) do
    args = OptionParser.parse(System.argv(), strict: [port: :integer, origin: :string, "clear-cache": :boolean]) |> elem(0)
    :ets.new(:config, [:set, :protected, :named_table])
    :ets.insert(:config, {:port, args[:port]})
    :ets.insert(:config, {:origin, args[:origin]})
    Logger.info("Starting the application with args: #{inspect(args)}")
    ElixirCacheServer.Cache.newCache()
    CommandHandler.start_link(__MODULE__);
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
