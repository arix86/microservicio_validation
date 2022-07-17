defmodule ExPoll.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger
  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExPoll.Repo,
      # Start the Telemetry supervisor
      ExPollWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExPoll.PubSub},
      # Start the Endpoint (http/https)
      ExPollWeb.Endpoint,
      {Task.Supervisor, name: SupervisorTareas},
      %{
        id: ExRabbitPool.PoolSupervisor,
        start:
          {ExRabbitPool.PoolSupervisor, :start_link,
           [
             [
               rabbitmq_config: AlbertoAmqp.Config.get(),
               connection_pools: Application.get_env(:alberto_amqp_client, :pools)
             ]
           ]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExPoll.Supervisor]
    s = Supervisor.start_link(children, opts)
    ExPoll.Net.world()
    ExPoll.Net.pg2("node")
    AlbertoAmqp.Client.initialize()
    start_new_amqp_pool()
    s
  end

  defp start_new_amqp_pool() do
    # Consumers que usan el pool
    subscribed =
      :alberto_amqp_client
      |> Application.get_env(:queues)
      |> Enum.map(
        &ExPoll.QueuesDefinitions.OnCreateGeneric.start_link(
          pool_id: :consumers_pool,
          queue: &1.config.queue
        )
      )

    Logger.info("Suscribed to #{inspect(subscribed)}")
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExPollWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule ExPoll.Net do
  require Monad.Error, as: Error
  import Error
  @etcd_key "/hosts"
  @deps ["nodeservice", "userservice", "searchservice"]
  def pg2(a) do
    case :pg2.get_closest_pid(a) do
      {:error, a} -> Error.fail(a)
      a -> Error.return(a)
    end
  end

  defp etcdc_nodes(%{:node => %{:nodes => nodes}}), do: Error.return(nodes)
  defp etcdc_nodes(a), do: Error.fail("etcd internal error #{inspect(a)}")

  def world do
    Error.m do
      n <- :etcdc.get(@etcd_key)
      configs <- n |> etcdc_nodes

      Error.return(
        configs
        |> Enum.filter(&(&1.key |> String.contains?(@deps)))
        |> Enum.map(
          &(&1
            |> Map.get(:value)
            |> String.to_atom()
            |> Node.connect())
        )
      )
    end
  end
end
