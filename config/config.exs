# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sam_media,
  ecto_repos: [SamMedia.Repo]

# Configures the endpoint
config :sam_media, SamMediaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YvtfSVkLyZ80hEOomUmx7PvqLh+LjAoL7TcAV4zu0l4EW0g2gqsfiqe2ApEae9zU",
  render_errors: [view: SamMediaWeb.ErrorView, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :sam_media, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      # phoenix routes will be converted to swagger paths
      router: SamMediaWeb.Router,
      # (optional) endpoint config used to set host, port and https schemes.
      endpoint: SamMediaWeb.Endpoint
    ]
  }

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :commanded_ecto_projections,
  repo: SamMedia.Repo

config :commanded, SamMedia.Order.Aggregates.Order,
  snapshot_every: 5,
  snapshot_version: 1

config :eventstore, registry: :distributed

config :vex,
  sources: [
    SamMedia.Order.Validators,
    SamMedia.Support.Validators,
    Vex.Validators
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
