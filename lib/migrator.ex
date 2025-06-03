defmodule Ectoapp.Migrator do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :ectoapp

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def create do
    load_app()

    for repo <- repos() do
      create_database(repo)
    end
  end

  def seed do
    load_app()

    for repo <- repos() do
      seed_database(repo)
    end
  end

  def seed_database(repo) do
    case Ecto.Migrator.with_repo(repo, &eval_seed(&1)) do
      {:ok, {:ok, _fun_return}, _apps} ->
        IO.puts("The seed database for #{inspect(repo)} has been executed with success")
        :ok

      {:ok, {:error, reason}, _apps} ->
        IO.puts(
          "The seed database for #{inspect(repo)} has been failed with reason: #{inspect(reason)}"
        )

        {:error, reason}

      {:error, term} ->
        IO.puts(
          "The seed database for #{inspect(repo)} has been failed with term: #{inspect(term)}"
        )

        {:error, term}
    end
  end

  defp eval_seed(_repo) do
    seeds_file = "#{:code.priv_dir(@app)}/repo/seeds.exs"

    if File.regular?(seeds_file) do
      {:ok, Code.eval_file(seeds_file)}
    else
      {:error, "Seeds file not found."}
    end
  end

  defp create_database(repo) do
    case repo.__adapter__.storage_up(repo.config) do
      :ok ->
        IO.puts("The database for #{inspect(repo)} has been created")

      {:error, :already_up} ->
        IO.puts("The database for #{inspect(repo)} has already been created")

      {:error, term} when is_binary(term) ->
        raise "The database for #{inspect(repo)} couldn't be created: #{term}"

      {:error, term} ->
        raise "The database for #{inspect(repo)} couldn't be created: #{inspect(term)}"
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
