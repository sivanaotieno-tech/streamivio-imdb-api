import Config

config :streamivio_imdb_api, StreamivioImdbApi.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")],
  server: true,
  secret_key_base: String.duplicate("dev-secret-key-base-", 4)

config :logger, :level, :info
