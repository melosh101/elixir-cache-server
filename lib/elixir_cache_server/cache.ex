defmodule ElixirCacheServer.Cache do
  def newCache do
    :ets.new(:cache, [:set, :protected])
  end

  def get(key) do
    :ets.lookup(:cache, key)
  end

  def put(key, value) do
    :ets.insert(:cache, {key, value})
  end
end
