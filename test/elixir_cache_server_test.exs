defmodule ElixirCacheServerTest do
  use ExUnit.Case
  doctest ElixirCacheServer

  test "greets the world" do
    assert ElixirCacheServer.hello() == :world
  end
end
