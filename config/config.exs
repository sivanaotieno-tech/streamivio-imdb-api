import Config

config :streamivio_imdb_api, StreamivioImdbApi.Endpoint,
  url: [host: "localhost"],
  render_errors: [formats: [json: StreamivioImdbApi.ErrorJSON], layout: false],
  check_origin: false

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
