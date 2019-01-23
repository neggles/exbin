# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :exbin, :tcp_port, (System.get_env("TCP_PORT") || "9999") |> String.to_integer()
config :exbin, :tcp_ip, (System.get_env("TCP_IP") || "127.0.0.1") |> to_charlist() |> :inet.parse_address() |> elem(1)
# General application configuration
config :exbin,
  ecto_repos: [ExBin.Repo]

# Configures the endpoint
config :exbin, ExBinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QTUmA1QFHVBkDuPSs30uWtJns/XEhCRNxrrIEzGrp9KyOQ4eGNp6AS7fgIIxTxXi",
  render_errors: [view: ExBinWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExBin.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
