defmodule ExPollWeb.Script do
  use ExPollWeb, :controller
  require Monad.Error, as: Error
  import Error
  require Logger
  def pg2(a) do
    case :pg2.get_closest_pid(a) do
      {:error, a} -> Error.fail(a)
      a -> Error.return(a)
    end
  end
  def search_type_m(type, q, f, to, sortf, ord) do
    Error.m do
      pid <- pg2(:searchservice)
      pid |> GenServer.call({:complex_system_match, type, "estatico", q, f, to, sortf<>":"<>ord}) |> return
    end
  end

  def get_node_m(nodo_id) do
    Error.m  do
      pid <- pg2("node")
      n <-pid |> GenServer.call({:node_m, nodo_id}, 30000)
      list_to_map(n) |> return
    end
  end
  def list_to_map(x) do
    Map.from_struct(x) |> Map.delete(:__meta__) |> Map.delete(:path) |> Map.delete(:id)
   #|>IO.inspect()
  end
  def search_(conn, params) do
    IO.inspect('##############################')
    IO.inspect(conn)
    IO.inspect('##############################')
    IO.inspect(params)
    IO.inspect('##############################')
    res=search_update()
    httpResponse(conn, 200, res)
end
def httpResponse(conn, status, data) do
  conn
  |> Plug.Conn.put_resp_header("content-type", "application/json; charset=utf-8")
  |> Plug.Conn.send_resp(status, Poison.encode!(data, pretty: true))
end
    def search_update() do
      query = ~s({
        "bool": {
            "must": [
            ],
            "should": [
              {
                  "term": {
                      "deleted": false
                  }
              },
              {
                  "bool": {
                      "must_not": {
                          "exists": {
                              "field": "deleted"
                          }
                      }
                  }
              }
            ]
        }
    })
      |> Poison.decode!()

      search_type_m("inscripcion", query, "0", "5", "inserted_at", "desc")
      |> case do
        {:ok, res} ->
          res["hits"]["hits"]
          |> Enum.map(fn item -> item["_id"] end)
          |> Enum.map(fn item ->
            # {:ok, res} = Calls.get_node_m(item)
            # res
            get_node_m(item)
            |> case do
              {:ok, res} ->
                IO.inspect("got data #{item}")
                res
              error ->
                IO.inspect("Error buscando el nodo #{item}. Error: #{inspect error}")
                nil
            end
          end)
          |> Enum.filter(fn item -> item != nil end)
        {:error, error} ->
          IO.inspect("Error buscando los expedientes en searchservice. #{inspect error}")
      end
    end

  end
