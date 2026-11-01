defmodule Mix.Tasks.Imdb.Import do
  use Mix.Task

  @shortdoc "Import IMDb title basics and ratings TSV files into Mnesia"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    case args do
      [basics_path, ratings_path] ->
        Mix.shell().info("Importing title basics from #{basics_path} ...")
        basics_count = StreamivioImdbApi.DatasetImporter.import_basics(basics_path)
        Mix.shell().info("Imported #{basics_count} title records.")

        Mix.shell().info("Importing ratings from #{ratings_path} ...")
        ratings_count = StreamivioImdbApi.DatasetImporter.import_ratings(ratings_path)
        Mix.shell().info("Imported #{ratings_count} rating records.")
      _ ->
        Mix.raise("Usage: mix imdb.import PATH_TO_title.basics.tsv PATH_TO_title.ratings.tsv")
    end
  end
end
