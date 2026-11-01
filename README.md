# Streamivio IMDb API

A self-hosted IMDb metadata service for Streamivio, built with **Elixir, Phoenix, and Mnesia**.

> This repository is an independent integration project. IMDb is the source of the public datasets; this is not an IMDb-owned or IMDb-endorsed API.

## Technology

- Elixir
- Phoenix Framework and Plug/Cowboy
- Mnesia for local metadata storage
- Jason for JSON
- IMDb non-commercial datasets as the metadata source

## Current API

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/ping` | Health check |
| GET | `/api/:tconst` | Retrieve a title by IMDb ID |
| GET | `/api/search?q=...` | Search imported titles |
| GET | `/api/search?q=...&type=movie` | Filter by title type |
| GET | `/api/search?q=...&year=2024` | Filter by start year |
| GET | `/api/search?q=...&limit=20&offset=0` | Paginate results |

Search only returns records that have been imported into the local Mnesia database. A newly deployed instance will not contain the full IMDb catalogue until dataset import is configured and completed.

## Requirements

- Elixir 1.14 or newer
- Erlang/OTP compatible with your Elixir version
- Mix

## Run locally

```bash
mix deps.get
mix compile
mix run --no-halt
```

The server listens on port 4000 by default. Set `PORT` to change it.

Test the health endpoint:

```bash
curl http://localhost:4000/api/ping
```

## Search examples

```bash
curl "http://localhost:4000/api/search?q=one%20piece&limit=10"
curl "http://localhost:4000/api/search?q=one%20piece&type=tvSeries"
curl "http://localhost:4000/api/tt0388629"
```

## Dataset and licensing

The intended metadata source is IMDb's downloadable public datasets at <https://datasets.imdbws.com/>. Review IMDb's current dataset terms and attribution requirements before downloading, redistributing, or using the data commercially. Public availability does not automatically grant commercial redistribution rights.

The original dataset is updated periodically by IMDb; this API is not a real-time IMDb feed. Do not describe ratings as live.

## Production notes

- Persist the Mnesia schema on a durable volume. Ephemeral server filesystems will lose the local database on restart.
- Configure TLS at the hosting proxy or load balancer.
- Add rate limiting and request logging before exposing the service publicly.
- Run dataset imports as a controlled background job; do not import the full dataset during web-server startup.
- Keep Streamivio playback URLs and playback authorization separate from IMDb metadata. IMDb metadata does not provide streaming rights or video files.

## License

The application code in this repository is MIT licensed. IMDb datasets remain subject to IMDb's own terms and are not relicensed by this project.
