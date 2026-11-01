defmodule StreamivioImdbApi.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StreamivioImdbApi.Store,
      StreamivioImdbApi.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: StreamivioImdbApi.Supervisor)
  end
end
