defmodule ExPoll.ETL do
  defp etl() do
    with {:ok, file} <- File.read("payload.json"),
         {:ok, data} <- Jason.decode(file),
         {:ok, empleado} <- Map.fetch(data, "empleados") do
      empleado |> Enum.map(fn x -> x['sueldo'] end) |> Enum.sum()
    end
  end

  def write_payload(payload) do
    x = File.write("payload.json", payload)

    case x do
      :ok -> etl()
      {:error, posix} -> Logger.info("Payload Write Error---- #{inspect(posix)}")
    end
  end
end
