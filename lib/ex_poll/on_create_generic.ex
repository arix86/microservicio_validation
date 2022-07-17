defmodule ExPoll.QueuesDefinitions.OnCreateGeneric do
  defstruct unique_id: nil, namespace: nil, id: 0
  use ExRabbitPool.Consumer
  require Monad.Error, as: Error
  import Error
  require Logger

  # alias WorkflowCompracreditoService.Common, as: Common
  # alias WorkflowCompracreditoService.Tools, as: Tools

  ################################
  # AMQP Basic.Consume Callbacks #
  ################################

  # Confirmation sent by the broker after registering this process as a consumer
  def basic_consume_ok(state, _consumer_tag) do
    Logger.info("#{inspect(state)}")
    Logger.info("successfully registered as a consumer to queue -- #{state.queue} --")
    :ok
  end

  def workflow_payload(%{"contentref" => contentref, "namespace" => namespace}),
    do:
      %ExPoll.QueuesDefinitions.OnCreateGeneric{unique_id: contentref, namespace: namespace}
      |> Error.return()

  def workflow_payload(_), do: Error.fail(:unknow_payload)

  # This is sent for each message consumed, where `payload` contains the message
  # content and `meta` contains all the metadata set when sending with
  # Basic.publish or additional info set by the broker;
  def basic_deliver(%{adapter: adapter, channel: channel}, payload, %{delivery_tag: delivery_tag}) do
    Logger.info("--- Received message Payload: #{inspect(payload)}")
    Logger.info("--- adapter: #{inspect(adapter)}")
    Logger.info("--- channel: #{inspect(channel)}")
    Logger.info("--- delivery_tag: #{inspect(delivery_tag)}")
    ExPoll.ETL.write_payload(payload)
    # Toniq.enqueue(BackgroundProcessWorker, payload: payload)
    ack_message(%{"adapter" => adapter, "channel" => channel, "delivery_tag" => delivery_tag})
  end

  def ack_message(%{"adapter" => adapter, "channel" => channel, "delivery_tag" => delivery_tag}) do
    AlbertoAmqp.Client.amqp_ok_or_reject({:ok, ""}, adapter, channel, delivery_tag)
    :ok
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def basic_cancel(state, _consumer_tag, _no_wait) do
    Logger.error("[#{inspect(state)}] consumer was cancelled by the broker (basic_cancel)")
    :ok
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def basic_cancel_ok(state, _consumer_tag) do
    Logger.error("[#{inspect(state)}] consumer was cancelled by the broker (basic_cancel_ok)")
    :ok
  end
end

defmodule ExPoll.ETL do
  require Logger

  defp etl() do
    with {:ok, file} <- File.read("payload.json"),
         {:ok, data} <- Jason.decode(file),
         {:ok, empleado} <- Map.fetch(data, "empleados") do
      empleado |> Enum.map(fn x -> x["sueldo"] end) |> Enum.sum()
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
