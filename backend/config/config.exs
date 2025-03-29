# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :farmshift_backend,
  ecto_repos: [FarmshiftBackend.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :farmshift_backend, FarmshiftBackendWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: FarmshiftBackendWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: FarmshiftBackend.PubSub,
  live_view: [signing_salt: "e96XCt0f"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian configuration
config :farmshift_backend, FarmshiftBackend.Auth.Guardian,
  issuer: "farmshift_backend",
  secret_key: "v1BsTpbgODOcA+eQwQ19wQEZ9v5nkIkzdMRvjYyIQtS2+YwXbBGT1QP5iJBKmRAK"

# CORS configuration
config :corsica,
  origins: ["http://localhost:3000", "http://localhost:5173", "http://127.0.0.1:3000", "http://127.0.0.1:5173"],
  allow_headers: ["content-type", "accept", "authorization", "origin"],
  allow_methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allow_credentials: true,
  max_age: 600

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
