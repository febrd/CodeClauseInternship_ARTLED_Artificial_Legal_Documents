defmodule LegalDoc.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :status, :string, default: "PENDING"
    field :title, :string, default: "-"
    field :summary, :string, default: "-"
    field :sentiment, :string, default: "-"
    field :file_path, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title, :summary, :sentiment, :status, :file_path])
    |> validate_required([:file_path]) # Only validate file_path
  end
end
