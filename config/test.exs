use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sam_media, SamMediaWeb.Endpoint,
  http: [port: 4002],
  server: false,
  pubsub: [name: SamMedia.PubSub, adapter: Phoenix.PubSub.PG2, pool_size: 1]

# Print only warnings and errors during test
config :logger, level: :warn

config :commanded, registry: :local
config :eventstore, registry: :local

# Configure your database
#
config :eventstore, EventStore.Storage,
  migration_timestamps: [type: :naive_datetime_usec],
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "sam_media_eventstore_test",
  hostname: "localhost",
  pool_size: 10

# Configure the read store database
config :sam_media, SamMedia.Repo,
  migration_timestamps: [type: :naive_datetime_usec],
  username: "postgres",
  password: "postgres",
  database: "sam_media_readstore_test",
  hostname: "localhost",
  pool_size: 10
