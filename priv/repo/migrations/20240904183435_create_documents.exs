defmodule LegalDoc.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string, size: 10000   # Menetapkan batasan panjang 10000 karakter
      add :summary, :string, size: 10000 # Menetapkan batasan panjang 10000 karakter
      add :sentiment, :string
      add :status, :string
      add :file_path, :string

      timestamps(type: :utc_datetime)
    end
  end
end
