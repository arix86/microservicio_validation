defmodule Script do

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
    x <-pid |> GenServer.call({:node_m, nodo_id}, 30000)
    list_to_map(x) |> return
  end
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

    search_type_m("inscripcion", query, "0", "1000", "inserted_at", "desc")
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
