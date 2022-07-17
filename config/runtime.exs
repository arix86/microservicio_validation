import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/ex_poll start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
# Configure your database
config :ex_poll, ExPoll.Repo,
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_PASS"),
  database: "saga",
  hostname: System.get_env("DATABASE_HOST"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 3

# # Configure your database
# config :extendedservice, Extendedservice.Repo,
#   url:
#     "ecto://#{System.get_env("DATABASE_USER")}:#{System.get_env("DATABASE_PASS")}@#{
#       System.get_env("DATABASE_HOST")
#     }:#{System.get_env("DATABASE_PORT")}/#{System.get_env("DATABASE_NAME")}",
#   show_sensitive_data_on_connection_error: true,
#   pool_size: System.get_env("DATABASE_POOL_SIZE") |> String.to_integer(),
#   queue_target: 5000

# config :toniq, redis_url: System.get_env("REDIS_URL")
# # "redis://redis-qa-service:6379/4"

config :ex_poll, ExPoll.Endpoint,
  http: [
    port: System.get_env("HTTP_PORT") |> String.to_integer()
  ],
  server: true,
  debug_errors: false,
  code_reloader: false,
  check_origin: false

config :phoenix, :json_library, Jason

# Do not include metadata nor timestamps in development logs
# config :logger,
#  backends: [{FlexLogger, :logger_name}]

# config :logger,
# backends: [{FlexLogger, :logger_name}]

config :logger, :logger_name,
  logger: :console,
  # this is the loggers default level
  default_level: :off,

  # override default levels
  level_config: [application: :ex_poll, level: :info],
  # backend specific configuration
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: [:request_id]

config :logger,
  handle_otp_reports: false,
  handle_sasl_reports: false

config :sasl, sasl_error_logger: false
config :sasl, errlog_type: :error

config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :etcdc,
  etcd_host: System.get_env("ETCD_HOST"),
  etcd_client_port: System.get_env("ETCD_PORT") |> String.to_integer()

config :alberto_amqp_client,
  pools: [
    [
      name: {:local, :producers_pool},
      worker_module: ExRabbitPool.Worker.RabbitConnection,
      size: 5,
      max_overflow: 0
    ],
    [
      name: {:local, :consumers_pool},
      worker_module: ExRabbitPool.Worker.RabbitConnection,
      size: 10,
      max_overflow: 0
    ]
  ]

config :alberto_amqp_client,
  queues: [
    %{
      module: AlbertoAmqp.Client.WorkflowDefault,
      config: %{
        queue: "on_create_solicitud_compra_credito",
        exchange: "on_create_solicitud_compra_credito",
        queue_error: "on_create_solicitud_compra_credito_error",
        queue_arguments: [
          {"x-dead-letter-exchange", :longstr, ""},
          {"x-dead-letter-routing-key", :longstr, "on_create_solicitud_compra_credito_error"}
        ]
      }
    }
  ]
