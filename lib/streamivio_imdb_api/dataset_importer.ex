defmodule StreamivioImdbApi.DatasetImporter do
  alias StreamivioImdbApi.Store

  @batch_size 1_000

  def import_basics(path) do
    import_file(path, fn fields ->
      case fields do
        [id, type, primary, original, adult, start_year, end_year, runtime, genres | _] ->
          {:imdb_titles, id, type, clean(primary), clean(original), adult == "1",
           number(start_year), number(end_year), number(runtime), split_genres(genres)}
        _ -> nil
      end
    end, &Store.write_titles/1)
  end

  def import_ratings(path) do
    import_file(path, fn fields ->
      case fields do
        [id, average, votes | _] ->
          case Float.parse(average) do
            {rating, _} -> {:imdb_ratings, id, rating, number(votes) || 0}
            :error -> nil
          end
        _ -> nil
      end
    end, &Store.write_ratings/1)
  end

  defp import_file(path, parser, writer) do
    if not File.exists?(path), do: raise("Dataset file not found: #{path}")

    path
    |> File.stream!([], :line)
    |> Stream.drop(1)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Stream.map(&String.trim_trailing(&1, "\r"))
    |> Stream.map(&String.split(&1, "\t", trim: false))
    |> Stream.map(parser)
    |> Stream.reject(&is_nil/1)
    |> Stream.chunk_every(@batch_size)
    |> Enum.reduce(0, fn batch, total ->
      case writer.(batch) do
        :ok -> total + length(batch)
        {:error, reason} -> raise "Dataset batch import failed: #{inspect(reason)}"
      end
    end)
  end

  defp clean("\\N"), do: nil
  defp clean(value), do: value

  defp number("\\N"), do: nil
  defp number(value) do
    case Integer.parse(value) do
      {number, _} -> number
      :error -> nil
    end
  end

  defp split_genres("\\N"), do: []
  defp split_genres(value), do: String.split(value, ",", trim: true)
end
