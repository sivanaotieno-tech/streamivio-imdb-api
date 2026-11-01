defmodule StreamivioImdbApi.Store do
  use GenServer

  @titles :imdb_titles
  @ratings :imdb_ratings

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok) do
    :mnesia.start()
    create_table(@titles, [:tconst, :title_type, :primary_title, :original_title, :is_adult, :start_year, :end_year, :runtime_minutes, :genres])
    create_table(@ratings, [:tconst, :average_rating, :num_votes])
    {:ok, %{}}
  end

  defp create_table(name, attributes) do
    case :mnesia.create_table(name, attributes: attributes, disc_copies: [node()]) do
      {:atomic, :ok} -> :ok
      {:aborted, {:already_exists, ^name}} -> :ok
      {:aborted, reason} -> raise "Could not create Mnesia table #{name}: #{inspect(reason)}"
    end
  end

  def get_title(tconst) do
    case :mnesia.transaction(fn -> :mnesia.read(@titles, tconst) end) do
      {:atomic, [record]} -> {:ok, record_to_map(record)}
      {:atomic, []} -> :not_found
      {:aborted, reason} -> {:error, reason}
    end
  end

  def search(params) do
    query = params |> Map.get("q", "") |> String.trim() |> String.downcase()
    type = params["type"]
    year = parse_integer(params["year"])
    limit = params |> Map.get("limit", "20") |> parse_integer() |> clamp(1, 100)
    offset = params |> Map.get("offset", "0") |> parse_integer() |> max(0)

    if query == "" do
      {:error, :query_required}
    else
      case :mnesia.transaction(fn ->
        :mnesia.foldl(fn record, acc ->
          title = record_to_map(record)
          matches_query =
            String.contains?(String.downcase(title.primary_title || ""), query) or
              String.contains?(String.downcase(title.original_title || ""), query)

          matches_type = is_nil(type) or type == "" or title.title_type == type
          matches_year = is_nil(year) or title.start_year == year

          if matches_query and matches_type and matches_year, do: [title | acc], else: acc
        end, [], @titles)
      end) do
        {:atomic, matches} ->
          sorted = Enum.sort_by(matches, &String.downcase(&1.primary_title || ""))
          page = sorted |> Enum.drop(offset) |> Enum.take(limit)
          {:ok, %{results: page, total: length(sorted), limit: limit, offset: offset}}
        {:aborted, reason} -> {:error, reason}
      end
    end
  end

  defp record_to_map({:imdb_titles, tconst, title_type, primary_title, original_title, is_adult, start_year, end_year, runtime_minutes, genres}) do
    %{
      id: tconst,
      title_type: title_type,
      primary_title: primary_title,
      original_title: original_title,
      is_adult: is_adult,
      start_year: start_year,
      end_year: end_year,
      runtime_minutes: runtime_minutes,
      genres: genres
    }
  end

  defp parse_integer(nil), do: nil
  defp parse_integer(value) when is_integer(value), do: value
  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {number, ""} -> number
      _ -> nil
    end
  end

  defp clamp(value, low, high), do: value |> max(low) |> min(high)
end
