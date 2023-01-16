defmodule DerpWeb.Plugs.IPFSCors do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    put_resp_header(conn, "Access-Control-Allow-Origin", "127.0.0.1:5001")
    |> IO.inspect()
  end

end
