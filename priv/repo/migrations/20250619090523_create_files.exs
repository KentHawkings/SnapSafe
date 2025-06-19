defmodule SnapSafe.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :filename, :string, null: false
      add :content_type, :string, null: false
      add :size, :integer, null: false
      add :file_path, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:files, [:user_id])
    create unique_index(:files, [:file_path])
  end
end
