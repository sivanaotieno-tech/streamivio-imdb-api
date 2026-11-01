defmodule StreamivioImdbApi.ApiController do
  use Phoenix.Controller, formats: [:json]

  def ping(conn, _params) do
    json(conn, %{message: "pong", service: "streamivio-imdb-api"})
  end

  def show(conn, %{"tconst" => tconst}) do
    case StreamivioImdbApi.Store.get_title(tconst) do
      {:ok, title} ->
        rating = get_rating(tconst)
        json(conn, Map.merge(title, rating))
      :not_found ->
        conn |> put_status(:not_found) |> json(%{error: "title_not_found", id: tconst})
      {:error, _reason} ->
        conn |> put_status(:service_unavailable) |> json(%{error: "metadata_store_unavailable"})
    end
  end

  def search(conn, params) do
    case StreamivioImdbApi.Store.search(params) do
      {:ok, payload} -> json(conn, payload)
      {:error, :query_required} ->
        conn |> put_status(:bad_request) |> json(%{error: "query_required", message: "Provide a non-empty q parameter."})
      {:error, _reason} ->
        conn |> put_status(:service_unavailable) |> json(%{error: "metadata_store_unavailable"})
    end
  end

  defp get_rating(tconst) do
    case :mnesia.transaction(fn -> :mnesia.read(:imdb_ratings, tconst) end) do
      {:atomic, [{:imdb_ratings, ^tconst, average_rating, num_votes}]} ->
        %{rating: average_rating, votes: num_votes}
      _ ->
        %{rating: nil, votes: nil}
    end
  end
end
