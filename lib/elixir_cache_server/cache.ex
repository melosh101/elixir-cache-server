defmodule ElixirCacheServer.Cache do
  def newCache do
    :ets.new(:cache, [:set, :public, :named_table])
  end

  def get(key) do
    :ets.lookup(:cache, key)
  end

  def put(key, value) do
    :ets.insert(:cache, {key, value})
  end

  def clear do
    :ets.delete_all_objects(:cache)
  end
end
