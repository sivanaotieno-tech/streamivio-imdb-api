import Config

config :streamivio_imdb_api, StreamivioImdbApi.Endpoint,
  url: [host: "localhost"],
  render_errors: [formats: [json: StreamivioImdbApi.ErrorJSON], layout: false],
  pubsub_server: StreamivioImdbApi.PubSub,
  live_view: [signing_salt: "streamivio-imdb-api-salt"]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
