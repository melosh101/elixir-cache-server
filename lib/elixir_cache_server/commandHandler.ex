defmodule ElixirCacheServer.CommandHandler do
  alias ElixirCacheServer.Cache
  use GenServer

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Server Callbacks

  def init(:ok) do
    IO.puts("CommandHandler started. Type 'exit' to stop or 'clear-cache' to clear the cache.")
    {:ok, %{}, {:continue, :listen}}
  end

  def handle_continue(:listen, state) do
    listen_for_commands()
    {:noreply, state}
  end

  def handle_info({:command, "exit"}, state) do
    IO.puts("Exiting CommandHandler...")
    System.halt(1)
    {:stop, :normal, state}
  end

  def handle_info({:command, "clear-cache"}, state) do
    IO.puts("Clearing cache...")
    Cache.clear()
    listen_for_commands()
    {:noreply, state}
  end

  def handle_info({:command, _command}, state) do
    IO.puts("Unknown command. Type 'exit' to stop or 'clear-cache' to clear the cache.")
    listen_for_commands()
    {:noreply, state}
  end

  # Helper functions

  defp listen_for_commands do
    spawn(fn ->
      command = IO.gets("> ") |> String.trim()
      send(__MODULE__, {:command, command})
    end)
  end
end
