defmodule ExPollWeb.TenantController do
  use ExPollWeb, :controller

  def hello(conn, params) do
      IO.inspect('##############################')
      IO.inspect(conn)
      IO.inspect('##############################')
      IO.inspect(params)
      IO.inspect('##############################')
      httpResponse(conn, 200, %{"success" => true})
  end

  def httpResponse(conn, status, data) do
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
    |> Plug.Conn.send_resp(status, Poison.encode!(data, pretty: true))
  end
end
