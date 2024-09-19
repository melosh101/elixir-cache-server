defmodule ElixirCacheServer.CachePlug do
  use Plug.Builder
  require Logger
  alias ElixirCacheServer.Cache
  import Plug.Conn

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    pass: ["*/*"],
    body_reader: {ElixirCacheServer.BodyReader, :read_body, []}


  def init(opts), do: opts

  def call(conn, _opts) do
    method = conn.method;
    path = conn.request_path;
    origin = :ets.lookup(:config, :origin) |> hd |> elem(1)
    url = origin <> path
    cacheKey = method <> ":" <> url
    Logger.info(url)


    case method do
      m when m in ["HEAD", "GET"] ->
        handle_get(conn, url, cacheKey)

      m when m in ["POST", "PUT", "DELETE", "PATCH"] ->
        originRes = HTTPoison.request(method, url, conn.req_headers, conn.body_params)
        %{conn | resp_headers: originRes.headers } |> send_resp(200, originRes.body)

      _ -> conn |> send_resp(405, "Method not allowed") |> halt()
    end



  end


  defp handle_get(conn, url, cacheKey) do
    case Cache.get(cacheKey) do
      [] ->
        originRes = HTTPoison.get!(url, conn.req_headers, conn.body_params)

        Cache.put(cacheKey, %{body: originRes.body, headers: originRes.headers})
        Logger.info("cache headers: #{inspect(originRes.headers)}")
        %{conn | resp_headers: [{"X-Cache", "MISS"}] ++ originRes.headers } |> send_resp(200, originRes.body)


      [{_, value}] ->
        value.headers |> Enum.each(fn {k, v} -> conn |> put_resp_header(k, v) end)
        conn |> put_resp_header("X-Cache", "HIT")
          |> send_resp(200, value.body)

      _ ->
         conn |> send_resp(500, "Internal server error")
    end

  end
end
