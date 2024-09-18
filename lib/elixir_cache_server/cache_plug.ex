defmodule ElixirCacheServer.CachePlug do
  alias ElixirCacheServer.Cache
  import Plug.Conn
  import ElixirCacheServer.Cache
  def init(opts), do: opts

  def call(conn, _opts) do
    method = conn.method;
    path = conn.request_path;
    origin = conn.host;
    case Cache.get(method <> ":" <> path) do
       -> nil
        conn |> put_resp_header("cache", "MISS") |> send_resp(200, "Hello world" <> method <> ":" <> origin <> "/" <> path)
        Cache.put(method <> ":" <> path, "Hello world" <> method <> ":" <> path)

    end
    conn |> send_resp(200, "Hello world" <> method <> ":" <> path)

  end
end
