defmodule Ectoapp.Repo.Migrations.CreateCostumerTable do
  use Ecto.Migration

  def change do
    create table(:costumers) do
      add :email, :string, null: false

      timestamps(type: :utc_datetime)
    end

    execute """
    INSERT INTO costumers (email, inserted_at, updated_at)
    SELECT email, NOW(), NOW()
    FROM users
    WHERE email IS NOT NULL;
    """
  end
end
