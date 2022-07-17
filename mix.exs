defmodule ExPoll.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_poll,
      version: "0.1.0",
      elixir: "~> 1.11.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExPoll.Application, []},
      extra_applications: [:lager, :logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.9"},
      {:phoenix_ecto, "~> 4.4"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_sql, "~> 3.6"},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:poison, "~> 3.0"},
      {:httpoison, "~> 1.8.1", override: true},
      {:monad, git: "https://github.com/haroldvera/monad", branch: "develop"},
      {:etcdc, github: "haroldvera/etcdc"},
      {:hackney, "~> 1.16", override: true},
      {:albertocommon, git: "https://bitbucket.org/teamdox/albertocommon"},
      {:uuid, "~> 1.1"},
      {:elastix, "~> 0.10.0"},
      {:lager, "~> 3.9.2", override: true},
      {:alberto_amqp_client,
       git: "https://bitbucket.org/teamdox/alberto_amqp_client.git", tag: "0.0.7"},
      # {:exredis, ">= 0.0.0"},
      # {:toniq, ">=0.0.0"},
      {:timex, "~> 3.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
