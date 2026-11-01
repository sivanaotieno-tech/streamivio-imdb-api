import Config

config :streamivio_imdb_api, StreamivioImdbApi.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  server: false,
  secret_key_base: String.duplicate("test-secret-key-base-", 4)

config :logger, :level, :warning
